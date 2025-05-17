# -------------------------- --------------- EV Station Project: Data Exploration and Insights Using SQL -------------------- ------------------------------- #
#---------------Initial Setup and Full Table Overview
create database ev_station_project;
use ev_station_project;
SELECT 
    *
FROM
    ev_station;
	
#-----------------Total Payment by Payment Mode    
SELECT 
    payment_modes, ROUND(SUM(Total), 2) AS Total_payment
FROM
    ev_station
GROUP BY payment_modes
ORDER BY Total_payment DESC;

#------------Staffed vs Unstaffed Station Count
SELECT 
    staff, COUNT(staff) AS Counts
FROM
    ev_station
GROUP BY staff;

#-----------------Total Payment by Payment Modes (Staffed Stations Only)
SELECT 
    payment_modes, ROUND(SUM(Total), 2) AS Total_payment_staffed
FROM
    ev_station
WHERE
    staff = 'Staffed'
GROUP BY payment_modes;

#-----------------Unstaffed Station Revenue by Payment Mode
SELECT 
    payment_modes,
    ROUND(SUM(Total), 2) AS Total_payment_unstaffed
FROM
    ev_station
WHERE
    staff = 'Unstaffed'
GROUP BY payment_modes
ORDER BY Total_payment_unstaffed DESC;

#---------------------User Count by Zone
SELECT 
    zone, COUNT(ID) AS user_count
FROM
    ev_station
GROUP BY zone
ORDER BY user_count DESC;

#----------------------Station Count by Vendor
SELECT 
    vendor_name, COUNT(vendor_name) AS counts
FROM
    ev_station
GROUP BY vendor_name
ORDER BY counts DESC;

#------------------------Zone-wise Vendor Count with ROLLUP
SELECT 
    IF(GROUPING(zone), 'Total_Zone', zone) Zone,
    IF(GROUPING(vendor_name),
        'Total_count',
        vendor_name) Vendor,
    COUNT(vendor_name) AS user_count
FROM
    ev_station
GROUP BY zone , vendor_name WITH ROLLUP;

#------------------------Station Type, Zone, and Vendor Count with ROLLUP
SELECT 
    IF(GROUPING(station_type),
        'Total_Station',
        station_type) station_type,
    IF(GROUPING(zone), 'Total_Zone', zone) Zone,
    IF(GROUPING(vendor_name),
        'Total_count',
        vendor_name) Vendor,
    COUNT(vendor_name) AS user_count
FROM
    ev_station
GROUP BY station_type , zone , vendor_name WITH ROLLUP;

#-----------------------------Delhi-Specific Vendor Count by Zone
SELECT 
    IF(GROUPING(zone), 'Total_Zone', zone) Zone,
    IF(GROUPING(vendor_name),
        'Total_count',
        vendor_name) Vendor,
    COUNT(vendor_name) AS user_count
FROM
    ev_station
WHERE
    city = 'Delhi'
GROUP BY zone , vendor_name WITH ROLLUP;

#-----------------------Non-Delhi Vendor Count with Zone Breakdown
SELECT 
    IF(GROUPING(zone), 'Total_Zone', zone) Zone,
    IF(GROUPING(vendor_name),
        'Total_count',
        vendor_name) Vendor,
    COUNT(vendor_name) AS user_count,
    CASE
        WHEN city = 'Delhi' THEN 'Delhi'
        ELSE 'Non delhi'
    END AS zones
FROM
    ev_station
GROUP BY zone , vendor_name , zones WITH ROLLUP
HAVING zones = 'Non delhi';

#-----------------Zone-wise Revenue and Average per Station by Power Type
SELECT 
    zone,
    power_type,
    ROUND(SUM(Total), 2) AS zone_total,
    ROUND(AVG(Total), 2) AS avg_per_station
FROM
    ev_station
GROUP BY zone , power_type;

#--------------------------EV Station Availability and Revenue by Power Type (with ROLLUP)
SELECT 
    IF(GROUPING(zone), 'Total_Zone', zone) Zone,
    IF(GROUPING(power_type),
        'Total_count',
        power_type) Power_Type,
    ROUND(SUM(available), 2) AS EV_staion,
    ROUND(SUM(Total), 2) AS Total_amount
FROM
    ev_station
GROUP BY zone , power_type WITH ROLLUP;

#------------------------Count by Power Type, Station Type, and Vehicle Type (with ROLLUP)
SELECT 
    IF(GROUPING(power_type),
        'Total',
        power_type) power_type,
    IF(GROUPING(type), 'Total_type', type) type,
    COUNT(type) AS count_type,
    IF(GROUPING(vehicle_type),
        'Total_vehicle_type',
        vehicle_type) vehicle_type,
    COUNT(vehicle_type) AS count_vehicle_type
FROM
    ev_station
GROUP BY power_type , type , vehicle_type WITH ROLLUP;

#----------------------Ranking Station Types by Frequency
with count_type as (
SELECT 
    type, COUNT(type) AS c_type
FROM
    ev_station
GROUP BY type
) 
select type, dense_rank() over(order by c_type desc) as type_rank from count_type;

#--------------------Most Frequent Station Type
with count_type as (
SELECT 
    type, COUNT(type) AS c_type
FROM
    ev_station
GROUP BY type
), ranked as (select type,c_type ,dense_rank() over(order by c_type desc) as type_rank from count_type)(SELECT 
    type, c_type
FROM
    ranked
WHERE
    type_rank = 1);

#----------------------------Total Revenue by Power Type
SELECT 
    power_type, ROUND(SUM(Total), 2) AS total_rev
FROM
    ev_station
GROUP BY power_type
ORDER BY total_rev DESC;

#-------------------Power Type Popularity vs Availability
SELECT 
    power_type,
    COUNT(ID) AS station_count,
    SUM(available) AS total_ports,
    ROUND(SUM(Total), 2) AS total_revenue
FROM
    ev_station
GROUP BY power_type;

#----------------------EV Station Availability by Zone and Power Type
SELECT 
    zone, power_type, SUM(available) AS EV_staion
FROM
    ev_station
GROUP BY zone , power_type
ORDER BY zone , EV_staion DESC;
 
#------------------------Stations Open Late Night and Closing Very Late
SELECT 
    zone, vendor_name, open, close
FROM
    ev_station
WHERE
    open BETWEEN '00:00:00' AND '05:00:00'
HAVING close BETWEEN '23:00:00' AND '23:59:59'
ORDER BY open ASC;

#-------------------------Stations Open in the Morning and Close Late Evening (6 AM – 10 AM to 9 PM – 10 PM)
with zone_s as (
SELECT 
    zone, vendor_name, open, close
FROM
    ev_station
WHERE
    open BETWEEN '06:00:00' AND '10:00:00'
HAVING close BETWEEN '21:00:00' AND '22:00:00'
ORDER BY open ASC
) SELECT DISTINCT
    zone, COUNT(zone)
FROM
    zone_s
GROUP BY zone;

#-------------------Top 5 Highest Revenue Generating Stations
with ranked as (
select name,dense_rank() over(order by Total desc) as Ranke, Total from ev_station
) SELECT 
    Ranke, name, Total
FROM
    ranked
WHERE
    Ranke IN (1 , 2, 3, 4, 5);

#------------------------Time Analysis Improvements
SELECT 
    zone, COUNT(*) AS early_open_count
FROM
    ev_station
WHERE
    HOUR(open) BETWEEN 0 AND 6
GROUP BY zone
ORDER BY early_open_count DESC;

#-----------------------User Behavior by Vendor
SELECT 
    vendor_name,
    COUNT(ID) AS total_sessions,
    ROUND(SUM(Total) / COUNT(ID), 2) AS avg_revenue
FROM
    ev_station
GROUP BY vendor_name
ORDER BY avg_revenue DESC;

#--------------------Top Vendor in Each Zone
with ranked_vendors as (
    select zone, vendor_name, count(*) as count, rank() over (partition by zone order by count(*) desc) as rnk from ev_station group by zone, vendor_name
)SELECT 
    zone, vendor_name, count
FROM
    ranked_vendors
WHERE
    rnk = 1;







