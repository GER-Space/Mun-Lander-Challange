run lib_nav2.
run lib_lander.

stage.
wait 0.5.

set SHIP:NAME to "Mun Rescue".
set TARGET to "Mun Lander".


set_altitude (60,10.5).
run_node().

set_altitude (ETA:PERIAPSIS,10.5).
run_node().


function stop_at{
	parameter spot.

	local node_lng to mod(360+Body:ROTATIONANGLE+spot:LNG,360).
	
	// change node_eta to adjust for rotation:
	local t_wait_burn to 0.
	
	local rot_angle to t_wait_burn*360/Body:ROTATIONPERIOD.

	local ship_ref to mod(obt:lan+obt:argumentofperiapsis+obt:trueanomaly,360).
	local ship_2_node to mod((720 + node_lng+rot_angle - ship_ref),360).
	local node_eta to ship_2_node*OBT:PERIOD/360.
	local my_node to NODE(time:seconds + node_eta,0,0,-SHIP:VELOCITY:SURFACE:MAG).
	ADD my_node.
	
	run_stopping_node(spot). 
}


set coordinates to TARGET:GEOPOSITION.
stop_at (coordinates).
do_suecide_burn(coordinates).

clearscreen.

local d_target to round((SHIP:GEOPOSITION:POSITION - coordinates:POSITION):MAG,1).
print "We landed "+d_target +" m from our target".

// Throw this at the end of your script to have it print out the optimal Delta V.
if ship:status = "LANDED" {

    set M0 to 24.92998.
    set M1 to mass.
    set ISP to 350.
    set g0 to 9.80665.

    set DeltaV_used to g0*ISP*ln(M0/M1).

    set Rf to ship:body:radius + altitude.
    set Rcir to ship:body:radius + 100000.
    set u to ship:body:MU.
    set a to (Rf + Rcir)/2.
    set e to (Rcir - Rf)/(Rf + Rcir).
    set Vgrnd to 2*Rf*(constant():pi)/138984.38.
    set Vcir to sqrt(u/Rcir).
    set Vap to sqrt(((1 - e)*u)/((1 + e)*a)).
    set Vper to sqrt(((1 + e)*u)/((1 - e)*a)).
    set DeltaV_opt to (Vcir - Vap) + (Vper-Vgrnd).
    set Deviation to DeltaV_used - DeltaV_opt.

    print "You used " + round(Deviation,2) + "m/s more than the optimal" .

}