# -------------------------- --------------- EV Station Project: Data Exploration and Insights Using SQL -------------------- ------------------------------- #
#Initial Setup and Full Table Overview
create database ev_station_project;
use ev_station_project;
select * from ev_station;
	
#Total Payment by Payment Mode    
select payment_modes, round(sum(Total),2) as Total_payment from ev_station group by payment_modes order by Total_payment desc;

#Staffed vs Unstaffed Station Count
select staff, count(staff) as Counts from ev_station group by staff ;

#Total Payment by Payment Modes (Staffed Stations Only)
select payment_modes, round(sum(Total),2) as Total_payment_staffed from ev_station where staff = 'Staffed' group by payment_modes ;

#Unstaffed Station Revenue by Payment Mode
select payment_modes, round(sum(Total),2) as Total_payment_unstaffed from ev_station where staff = 'Unstaffed' group by payment_modes order by Total_payment_unstaffed desc;

#User Count by Zone
select zone, count(ID) as user_count from ev_station group by zone order by user_count desc;

#Station Count by Vendor
select vendor_name, count(vendor_name) as counts from ev_station group by vendor_name order by counts desc;

#Zone-wise Vendor Count with ROLLUP
select if(grouping(zone), 'Total_Zone', zone) Zone	,if(grouping(vendor_name), 'Total_count', vendor_name) Vendor, count(vendor_name) as user_count from ev_station group by zone, vendor_name with rollup;

#Station Type, Zone, and Vendor Count with ROLLUP
select if(grouping(station_type), 'Total_Station', station_type) station_type  ,if(grouping(zone), 'Total_Zone', zone) Zone	,if(grouping(vendor_name), 'Total_count', vendor_name) Vendor, count(vendor_name) as user_count from ev_station group by station_type,zone, vendor_name with rollup;

#Delhi-Specific Vendor Count by Zone
select if(grouping(zone), 'Total_Zone', zone) Zone	,if(grouping(vendor_name), 'Total_count', vendor_name) Vendor, count(vendor_name) as user_count from ev_station where city = 'Delhi' group by zone, vendor_name with rollup;

#Non-Delhi Vendor Count with Zone Breakdown
select if(grouping(zone), 'Total_Zone', zone) Zone	,if(grouping(vendor_name), 'Total_count', vendor_name) Vendor, count(vendor_name) as user_count, case when city = 'Delhi' then 'Delhi'
else 'Non delhi'
end as zones from ev_station group by zone, vendor_name,zones with rollup having zones = 'Non delhi';

#Zone-wise Revenue and Average per Station by Power Type
select zone, power_type, ROUND(SUM(Total), 2) AS zone_total, ROUND(AVG(Total), 2) as avg_per_station from ev_station group by zone, power_type;

#EV Station Availability and Revenue by Power Type (with ROLLUP)
select if(grouping(zone), 'Total_Zone', zone) Zone	,if(grouping(power_type), 'Total_count', power_type) Power_Type, round(sum(available),2) as EV_staion, round(sum(Total),2) as Total_amount from ev_station group by zone, power_type with rollup;

#Count by Power Type, Station Type, and Vehicle Type (with ROLLUP)
select if(grouping(power_type),'Total',power_type)power_type,if(grouping(type),'Total_type',type)type,count(type) as count_type ,if(grouping(vehicle_type),'Total_vehicle_type',vehicle_type)vehicle_type , count(vehicle_type)as count_vehicle_type from ev_station group by power_type,type,vehicle_type with rollup;

#Ranking Station Types by Frequency
with count_type as (
select type, count(type) as c_type from ev_station group by type 
) select type, dense_rank() over(order by c_type desc) as type_rank from count_type;

#Most Frequent Station Type
with count_type as (
select type, count(type) as c_type from ev_station group by type 
), ranked as (select type,c_type ,dense_rank() over(order by c_type desc) as type_rank from count_type)(select type,c_type from ranked where type_rank = 1);

#Total Revenue by Power Type
select power_type, round(sum(Total),2) as total_rev from ev_station group by power_type order by total_rev desc;

#Power Type Popularity vs Availability
select power_type, count(ID) as station_count, sum(available) as total_ports, round(sum(Total), 2) as total_revenue from ev_station group by power_type;

#EV Station Availability by Zone and Power Type
select zone, power_type ,sum(available) as EV_staion from ev_station group by zone,power_type order by zone,EV_staion desc;
 
#Stations Open Late Night and Closing Very Late
select zone, vendor_name, open, close from ev_station where open between '00:00:00' and '05:00:00' having close between '23:00:00' and '23:59:59'   order by open asc;

#Stations Open in the Morning and Close Late Evening (6 AM – 10 AM to 9 PM – 10 PM)
with zone_s as (
select zone , vendor_name, open, close from ev_station where open between '06:00:00' and '10:00:00' having close between '21:00:00' and '22:00:00' order by open asc
) select distinct zone, count(zone) from zone_s group by zone;

#Top 5 Highest Revenue Generating Stations
with ranked as (
	select name,dense_rank() over(order by Total desc) as Ranke, Total from ev_station
) select Ranke,name, Total from ranked where Ranke in (1,2,3,4,5);

#Time Analysis Improvements
select zone, count(*) as early_open_count from ev_station where hour(open) between 0 and 6 group by zone order by early_open_count desc;

#User Behavior by Vendor
select vendor_name, count(ID) as total_sessions,round(sum(Total)/count(ID), 2) as avg_revenue from ev_station group by vendor_name order by avg_revenue desc;

#Top Vendor in Each Zone
with ranked_vendors as (
    select zone, vendor_name, count(*) as count, rank() over (partition by zone order by count(*) desc) as rnk from ev_station group by zone, vendor_name
)select zone, vendor_name, count from ranked_vendors where rnk = 1;







