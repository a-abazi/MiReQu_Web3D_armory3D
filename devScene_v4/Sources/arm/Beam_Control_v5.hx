package arm;

import iron.math.Vec4;
import iron.math.Mat4;
import iron.math.Quat;
import iron.Scene;
import iron.object.Object;

import armory.trait.physics.RigidBody;
import armory.system.Event;

// NEW THRESHHolds for Stokes I and p 16.09.2020
class Beam_Control_v5 extends iron.Trait {

	@prop 
	var pump_laser_name : String = "LDM56_06";
	
	@prop 
	var beam_name : String = "Beam";
	
	@prop 
	var pol_arrow_name : String = "pol_arrows";

	@prop 
	var pol_torus_name : String = "pol_torus";

	@prop
	var rayNumber: Int = 5;

	@prop 
	var beamNumber: Int = 25;

	@prop
	var max_arrows: Int = 30;

	@prop 
	var updateTime:  Float = 0.025;
	
	@prop
	var laser_on : Bool = true;
	
	@prop
	var pol_on : Bool = false;

	@prop
	var timer_on : Bool = true;

	@prop
	var mask: Int = 2; // Collections Filtermask for RayCast contact with rigid bodys
	
	@prop 
	var beamdiameter: Float = 0.025;
	
	@prop 
	var arrow_diameter: Float = 0.5; 
	
	@prop 
	var arrow_length: Float = 0.5; 
	
	@prop 
	var arrow_dist: Float = 0.75; 
	

	var funName_BP: String = "GetChildProperties";

	var funName_NBP: String = "GetNewChildProperties";

	var funName_BP_Names: String = "GetChildPropertyNames";

	var funName_Dir: String = "GetBeamDirection";

	var funName_NDir: String = "GetNewBeamDirection";


	var calc_event:String = "Calc_Beams";

	var Proptraitname : String = "String_Beam_Ray_Traits";

	var arrName_subobjects: String = "arr_sub_objects";
	

	// Define Main Arrays (Arrays of Arrays)
	var main_Array_beams: Array <Dynamic> = [[]];
	var main_Array_sor:   Array <Dynamic> = [[]];
	var main_Array_pos:   Array <Dynamic> = [[]];
	var main_Array_dir:   Array <Dynamic> = [[]];
	var main_All_arrows: Array <Dynamic> = [[]];

	var calculation_on_sleep: Bool = false;
	var time = 0.0;
	
	var pump_laser: Object;
	var beam: Object;
	var pol_arrow: Object;


	public function new() {
		super();

		notifyOnInit(onInit);
		notifyOnUpdate(onUpdate);

	}	

	function onInit() {
		var beamNumber: Int = 25;
		var updateTime:  Float = 0.025;
		var object: Object = iron.Scene.global;

		pump_laser = Scene.active.root.getChild(pump_laser_name);
		beam = Scene.active.root.getChild(beam_name);
		pol_arrow = Scene.active.root.getChild(pol_arrow_name);

		if (object == null) return;
		if (object.properties == null) object.properties = new Map();
		object.properties.set("Laser_on",laser_on);
		object.properties.set("Pol_on",pol_on);

		object.properties.set("beamNumber",beamNumber);
		object.properties.set("updateTime",updateTime);
		
		Event.add(calc_event,onEventCB);
	}
	
	var once: Bool = true;
	var delay: Float = 1;
	function onUpdate(){
		// do something after init but a little time later (variable "delay")
		// without the delay, not alle objects are initialized and an error is given when these properties are called
		if (once){
			time += iron.system.Time.delta;
			if (time>= delay){
				Event.send(calc_event);
				once = false;
			}
			else return;
		}

		//timer, reset calculation on sleep after updatetime
		if (calculation_on_sleep && timer_on){
			var object: Object = iron.Scene.global;
			if (object == null) return;
			if (object.properties == null) object.properties = new Map();
			var updateTime: Float = object.properties.get("updateTime");
			time += iron.system.Time.delta;
			if (time >= updateTime){
				calculation_on_sleep = false;
				time = 0.0;
			}
		}
		
	}

	function onEventCB(){ // Event to calculate Beams and such
		var object: Object = iron.Scene.global;

		if (object == null) return;
		if (object.properties == null) object.properties = new Map();
		var laser_on: Bool = object.properties.get("Laser_on");
		
		if (timer_on){
			if (calculation_on_sleep) return;
			calculation_on_sleep = true;
			time = 0.0;
		}

		if (!laser_on) {
			var i=0;
			for (beam_array in main_Array_beams){
				polControl(beam_array, main_All_arrows[i]);
				despawnBeams(beam_array);
				i++;
			}
			return;
		}

		var blocked: Bool;

		main_Array_sor = [[]];
		main_Array_pos = [[]];
		main_Array_dir = [[]];
		//main_All_arrows: Array <Dynamic> = [[]]; //ToDo: check if this needs to be resetted when implementing sub beams

		main_Array_pos[0] = []; //Reset Array
		main_Array_pos[0].push(pump_laser.transform.world.getLoc());//add first position
		main_Array_dir[0] = [];
		main_Array_dir[0].push(pump_laser.transform.world.right());
		main_Array_sor[0] = [];
		main_Array_sor[0].push(pump_laser);

		

		for (i in 0...rayNumber){
			if (i<=main_Array_pos.length-1){
				
				// delete superfluous beam arrays and sub object array
				while (main_Array_beams.length>main_Array_pos.length){
					var to_del_Arr = main_Array_beams.pop();
					despawnBeams(to_del_Arr);
				}
				while (main_Array_beams.length>main_All_arrows.length){
					var to_del_Arr = main_All_arrows.pop();
					despawnSubobjects(to_del_Arr);
				}

				// Define an array of the currce Ray
				var main_Array: Array<Dynamic>  = [main_Array_beams[i],main_Array_sor[i],main_Array_pos[i],main_Array_dir[i]];
				var array_Pols: Array<Object> = main_All_arrows[i];
				
				// call the main method on specific Array of one Ray
				blocked = calc_pos_dir(main_Array);
				blocked = spawnBeams(main_Array, blocked);
				blocked = polControl(main_Array, array_Pols); //ToDO: Manage properties of subsources so this works again, now the subRays have no properties
				
				var curr_beams: Array<Object> = main_Array_beams[i];
				var curr_sources: Array<Object> = main_Array_sor[i];
				var curr_poss: Array<Vec4> = main_Array_pos[i];
				var curr_dirs: Array<Vec4> = main_Array_dir[i];

				// search the source objects for a new Ray spawning source e.g. Beamsplitter
				for (parent_index in 1...curr_sources.length){ // skip the first entry as it already spawns the array
					var source_object = curr_sources[parent_index];

					if (source_object == null) continue; // check 
					if (source_object.properties == null) source_object.properties = new Map();

					if (source_object.properties.get("spawnsRays") != null){
						var spawnsRays: Int = source_object.properties.get("spawnsRays");
						for (j in 0...spawnsRays){
							var parBeam: Object = curr_beams[parent_index-1];
							
							var beam_props = callTraitFunction(source_object,Proptraitname,funName_NBP,[parBeam,j]);

							var new_dir: Vec4 = callTraitFunction(source_object,Proptraitname,funName_NDir,[curr_dirs[parent_index-1],j] );
							var new_Beam = spawnEmptyBeam(false);
							
							new_Beam.properties = beam_props;

							var new_Beam_array: Array <Object> = [new_Beam];
							var new_sor_array: Array <Object> = [source_object];
							var new_pos_array: Array <Vec4> = [curr_poss[parent_index]]; // ToDo: change to Beam End when is implemented
							var new_dir_array: Array <Vec4> = [new_dir];

							main_Array_beams.push(new_Beam_array);
							main_Array_sor.push(new_sor_array);
							main_Array_pos.push(new_pos_array);
							main_Array_dir.push(new_dir_array);
							main_All_arrows.push([]);
						}
					}
				}
			}
			//trace(main_All_arrows.length);
		}
	}


	function spawnEmptyBeam(visible: Bool):Object {
		var object: Object;
		var objectName = beam_name;
		var matrix = null;
		var spawnChildren = false;

		iron.Scene.active.spawnObject(objectName, null, function(o: Object) {
			object = o;
			if (matrix != null) {
				object.transform.setMatrix(matrix);
			
				var rigidBody = object.getTrait(RigidBody);
				if (rigidBody != null) {
					object.transform.buildMatrix();
					rigidBody.syncTransform();
				}
			}
			object.visible = visible;
		}, spawnChildren);

		var arr_subobjects: Array<Object> = [];
		//if (object == null) return false;
		if (object.properties == null) object.properties = new Map();
		object.properties.set(arrName_subobjects,arr_subobjects);

		return object;
	}

	function callTraitFunction(object:Object, traitNamePropertyString:String, funName: String, funArguments:Array <Dynamic>):Dynamic{
		var result: Dynamic;
		// (Small helper) This function combines some dynamic haxe functions (especially Reflect) to call 
		//  correct instance of the trait of the object. In the beginning the traitname and such are calles


		// obtain new direction of Beam
		// Call correct Trait of correct Object
		var traitname: String = object.properties.get(traitNamePropertyString);
		var cname: Class<iron.Trait> = null; // call class name (trait), includes path and more
		if (cname == null) cname = cast Type.resolveClass(Main.projectPackage + "." + traitname);
		if (cname == null) cname = cast Type.resolveClass(Main.projectPackage + ".node." + traitname);
		var trait: Dynamic = object.getTrait(cname);
		// Call function of the correct instance of the trait, get new Direction
		var func = Reflect.field(trait, funName);

		if (func != null) {
			result = Reflect.callMethod(trait, func, funArguments);
		}
		else{
			trace("Error: dynamic function resulted in null value, Error in trait or function name");
			result = null;
		}

		return result;
	}

	function despawnBeams(arr_beams:Array <Object>){
        if (arr_beams!= null ){
            while(0<arr_beams.length){
                var curr_beam: Object = arr_beams.pop();
                if (curr_beam.properties!= null && curr_beam.properties.get(arrName_subobjects)){
                    var arr_visobj: Array<Object> = curr_beam.properties.get(arrName_subobjects);
                    while (arr_visobj.length>0) arr_visobj.pop().remove();
                }
                curr_beam.remove();
            }
        }    
	}

	function despawnSubobjects(arr_obj:Array <Object>){
        if (arr_obj!= null ){
            while(0<arr_obj.length)arr_obj.pop().remove();
        }
	}

	function calc_pos_dir(arrays : Array <Dynamic>):Bool{
		var object: Object = iron.Scene.global;
		var arr_beams: Array <Object> = arrays[0];
		var arr_sor: Array<Object> = arrays[1];
		var arr_pos: Array<Vec4> = arrays[2];
		var arr_dir: Array<Vec4> = arrays[3];

		var s_obj: Object = arr_sor[0];		
		if (s_obj == null) return false;

		if (object == null) return false;
		if (object.properties == null) object.properties = new Map();
		var beamNumber: Int = object.properties.get("beamNumber");

		var funName = funName_Dir;
		var blocked: Bool = true;
		
		// cycle through some integers limited by maximal beamNumber
		for (i in 0...beamNumber) {
			// RayCast, calculate From and to Vectors
			var vfrom = new Vec4().setFrom(arr_pos[i]);
			var vto = new Vec4().setFrom(arr_dir[i]);
			vto.x *= 1000;
			vto.y *= 1000;
			vto.z *= 1000;
			vto.add(vfrom);

			// Call the Raycast function
			var physics = armory.trait.physics.PhysicsWorld.active;
			var v_hit = new Vec4();
			var rb: Dynamic;
			var hit = physics.rayCast(vfrom, vto, 1, mask);
			rb = (hit != null) ? hit.rb : null;
			
			if (hit == null) break;
			var l_obj: Object = (hit != null) ? rb.object : null;
					  
			// obtain hit vector, add new position
			var hitPointWorld: Vec4 = rb != null ? physics.hitPointWorld : null;
			if (hitPointWorld != null) {
				v_hit.set(hitPointWorld.x, hitPointWorld.y, hitPointWorld.z, 1);
			}
			else v_hit = null;
			arr_pos.push(v_hit);        
			arr_sor.push(l_obj);
			
			// check if the object blocks the Beam, if not continue
			blocked = l_obj.properties.get("blocksBeam");
			if (i == beamNumber-1) blocked = true;
			if (blocked) break;
			
			// obtain new direction of Beam
			// Call correct Trait of correct Object
			if (l_obj.properties==null) break;
			arr_dir.push(callTraitFunction(l_obj,Proptraitname,funName,[arr_dir[i]]));
		} 
		return blocked;
	}

	function spawnBeams(arrays : Array <Dynamic>, blocked):Bool {
		var arr_beams: Array <Object> = arrays[0];
		var arr_sor: Array<Object> = arrays[1];
		var arr_pos: Array<Vec4> = arrays[2];
		var arr_dir: Array<Vec4> = arrays[3];
        
        var objectName: String  = beam_name;
		
		var childprops = new  Map<String,Dynamic>();

        // loop all previosly calculated position entries and spawn beams with correct properties
        for (i in 0...arr_pos.length) {
            var matrix: Mat4 = Mat4.identity(); 
            var spawnChildren: Bool = false;
            var loc = arr_pos[i];
            var rot = new Vec4();
		    var scale = new Vec4(1,beamdiameter,beamdiameter,1);
            var q = new Quat();
            var x = new Vec4(1,0,0,1);


            // setup transformation Matrix
            if (i==0){ // Special case for first Beam
                 var vec = new Vec4();
                 vec.setFrom(arr_pos[i]);
                 if (arr_pos.length==1) scale.x = 1000.;
                 else scale.x = vec.distanceTo(arr_pos[i+1]);
            }
            else if (i==arr_pos.length-1){ // other Beams
                    if (blocked) {
                        while(arr_pos.length-1<arr_beams.length){
                            arr_beams.pop().remove();
                        }
                        break;
                    }
                    scale.x = 1000.;
            }
            else {	//Special Case for last Beam
                var vec = new Vec4();
                vec.setFrom(arr_pos[i]);
                scale.x = vec.distanceTo(arr_pos[i+1]);
            }
            rot.add(arr_dir[i]);
            rot.normalize();
            q.fromTo(x,rot);
            matrix.compose(loc, q, scale);
			
			// Spawning or Updating the actual Beam Objects
            if (arr_beams[i] == null ){ // Beam needs to be Spawned
                var object: Object;
		        iron.Scene.active.spawnObject(objectName, null, function(o: Object) {
		        	object = o;
		        	if (matrix != null) {
		        		object.transform.setMatrix(matrix);
                    
		        		var rigidBody = object.getTrait(RigidBody);
		        		if (rigidBody != null) {
		        			object.transform.buildMatrix();
		        			rigidBody.syncTransform();
		        		}
		        	}
		        	object.visible = true;
				}, spawnChildren);
				
                var arr_subobjects: Array<Object> = [];
                if (object == null) return false;
			    if (object.properties == null) object.properties = new Map();
                object.properties.set(arrName_subobjects,arr_subobjects);

                arr_beams.push(object);
            }
            else { // Beam needs to be transformed
                var object: Object = arr_beams[i];
                object.transform.setMatrix(matrix);
				object.visible = true;
                var rigidBody = object.getTrait(RigidBody);
                if (rigidBody != null) rigidBody.syncTransform();
                
            }


			//Assigning correct properties to the Beams
            // write new properties to new Beam
			var curr_beam = arr_beams[i];
			if (curr_beam == null) return false;
			if (curr_beam.properties == null) curr_beam.properties = new Map();

            // Call current source object
			var source_object: Object = arr_sor[i];
			if (source_object == null) return false;
			if (source_object.properties == null) source_object.properties = new Map();
						
            // setup inital properties and call the Laser
            if (i==0){
				if (source_object == pump_laser) childprops = callTraitFunction(source_object, Proptraitname, funName_BP, [arr_beams[i], arr_pos[i], arr_dir[i]]);
				else childprops = curr_beam.properties.copy();
			}


            // get new properties from optical component, else properties remain unchanged
            if (i>0 && source_object.properties.get("changes_prop")){
				childprops = callTraitFunction(source_object, Proptraitname, funName_BP, [arr_beams[i-1], arr_pos[i], arr_dir[i]]);
			}


			//transfer new properties, except unique properties like array of subobjects, such values are only defined at spawn
			for (key in childprops.keys()){
				if (key == arrName_subobjects) continue;
				curr_beam.properties[key] = childprops[key];
			}

			if (curr_beam.properties["stokes_I"]<0.005){
				// curr_beam.remove();
				curr_beam.visible = false;
				//break;
			}
			
			

        }

        // remove unwanted beams and sub objects e.g. Polarization arrows
        while(arr_pos.length<arr_beams.length){
            var curr_beam: Object = arr_beams.pop();
            if (curr_beam.properties!= null && curr_beam.properties.get(arrName_subobjects)){
                var arr_subobjects: Array<Object> = curr_beam.properties.get(arrName_subobjects);
                while (arr_subobjects.length>0) arr_subobjects.pop().remove();
            }
            curr_beam.remove();
		}
	return false;
	}
	

	function polControl(arrays : Array <Dynamic>, arr_all_arrows: Array<Object>):Bool {	
		var arr_beams: Array <Object> = arrays[0];
		var arr_sor: Array<Object> = arrays[1];
		var arr_pos: Array<Vec4> = arrays[2];
		var arr_dir: Array<Vec4> = arrays[3];

		var return_bool: Bool = true;

        var objectName: String = pol_arrow_name;
        var arrow_num_total: Int = 0;

		var global_object: Object = iron.Scene.global;

		if (global_object == null) return return_bool;
		if (global_object.properties == null) global_object.properties = new Map();
		var pol_on: Bool = global_object.properties.get("Pol_on");
		var laser_on: Bool = global_object.properties.get("Laser_on");

		

        if (pol_on==false || laser_on == false){
            while (arr_all_arrows.length>0){
                var arrow = arr_all_arrows.pop();
                var parent: Object = arrow.properties.get("parent");
                if (parent.properties == null) parent.properties = new Map();
                var arrayofBeam: Array<Object> = parent.properties.get(arrName_subobjects);
                arrayofBeam.remove(arrow);
                arrow.remove();
            }
            return return_bool;
		}
        else{
            // loop all previosly calculated position entries and spawn beams with correct properties
            for (i in 0...arr_pos.length) {
                //if (i>=arr_beams.length && blocked) break;
                var beam: Object = arr_beams[i];
								
				var beam_length: Float;
				var numArrows: Int;
				
                if (beam == null) continue;
				if (beam.properties == null) beam.properties = new Map();
                var arrayofBeam: Array<Object> = beam.properties.get(arrName_subobjects);
				
				var stokes_I:   Float = beam.properties.get("stokes_I");
				var stokes_p:   Float = beam.properties.get("stokes_p");
				var stokes_psi: Float = beam.properties.get("stokes_psi");
				var stokes_chi: Float = beam.properties.get("stokes_chi");
				

				
				var pol_dir = new Vec4(0,Math.cos(stokes_psi),Math.sin(stokes_psi),1);
				pol_dir.normalize();
			
                //Determine Beam Length
                if (i == arr_pos.length - 1){
                    beam_length = 1000;
                }
                else{ 
                    var v1 = new Vec4().add(arr_pos[i]);
                    var v2 = new Vec4().add(arr_pos[i+1]);
                    beam_length = Vec4.distance(v1,v2);
                }

                // Determine Arrow number
                numArrows = (beam_length/arrow_dist < max_arrows) ? Std.int(beam_length/arrow_dist) : max_arrows;

				// Check if is state is polarized
				if (stokes_p< 0.95 || stokes_I <0.005) continue;
				

				var scale: Vec4;
				var flip = false;

				//check if state ist linear or ellipitical, and wheather to use arrows or torus as 3Dmodel
				if ((Math.abs(stokes_chi))>0.1){
					objectName = pol_torus_name;
					var stokes_vec: Vec4 = new Vec4( // https://en.wikipedia.org/wiki/Stokes_parameters
						stokes_I,
						stokes_I*stokes_p*Math.cos(stokes_psi*2)*Math.cos(stokes_chi*2),
						stokes_I*stokes_p*Math.sin(stokes_psi*2)*Math.cos(stokes_chi*2),
						stokes_I*stokes_p*Math.sin(stokes_chi*2)
					);
					var Ip: Float = Math.sqrt(Math.pow(stokes_vec.y,2) + Math.pow(stokes_vec.z,2) + Math.pow(stokes_vec.w,2));
					var absL: Float = Math.sqrt(Math.pow(stokes_vec.y,2) + Math.pow(stokes_vec.z,2));
					
					var A: Float = Math.sqrt(1./2.*(Ip+absL));
					var B: Float = Math.sqrt(1./2.*(Ip-absL));
					var V: Float = stokes_vec.w;

					scale = new Vec4(arrow_diameter,arrow_length*A* stokes_I,arrow_length*B* stokes_I,1);
					
					if (V<0) flip = true;
				} 
				else{
					objectName = pol_arrow_name;
					scale = new Vec4(arrow_diameter,arrow_length * stokes_I,arrow_diameter ,1);
				}
                // Define Transform for Array
                
                var q = new Quat();
                var q2 = new Quat();
				var x = new Vec4(1,0,0,1); //new Vec4().add(arr_dir[i]); //
				var y = new Vec4(0,1,0,1);
                var beam_dir = new Vec4().setFrom(arr_dir[i]);

                q.fromTo(x,beam_dir);
                q2.fromTo(y,pol_dir);
                q.multquats(q,q2);

				if (flip) q.mult(new Quat(pol_dir.x,pol_dir.y,pol_dir.z,0));

                for (k in 0...(arrayofBeam.length-numArrows)) {
                    if (arrayofBeam[arrayofBeam.length-k]!= null ) arrayofBeam.pop().remove();
                    else arrayofBeam.pop();
                }
            
				//trace(arrayofBeam);
                // Define Transform for individual Objects
                for (j in 0...numArrows){
                    arrow_num_total++;
                    var matrix: Mat4 = Mat4.identity(); 
                    var spawnChildren: Bool = false;
                    var loc = new Vec4().add(arr_dir[i]);
                    loc.normalize();
                    loc.mult((j+1)*arrow_dist);
					loc.add(arr_pos[i]);
                    matrix.compose(loc, q, scale);

					// Spawn/update object and check for correct model
                    if (arrayofBeam[j] == null ){
                        var object: Object;
                        iron.Scene.active.spawnObject(objectName, null, function(o: Object) {
                            object = o;
                            if (matrix != null) {
                                object.transform.setMatrix(matrix);
                            
                                var rigidBody = object.getTrait(RigidBody);
                                if (rigidBody != null) {
                                    object.transform.buildMatrix();
                                    rigidBody.syncTransform();
                                }
                            }
                            object.visible = true;
                        }, spawnChildren);

                        if (object == null) return return_bool;
                        if (object.properties == null) object.properties = new Map();
                        object.properties.set("parent",beam);
                        arr_all_arrows.push(object);
                        arrayofBeam.push(object);
					}
					else if (arrayofBeam[j].name != objectName){
						var remObject: Object = arrayofBeam[j];
						arrayofBeam.remove(remObject);
						remObject.remove();
						
						var object: Object;
                        iron.Scene.active.spawnObject(objectName, null, function(o: Object) {
                            object = o;
                            if (matrix != null) {
                                object.transform.setMatrix(matrix);
                            
                                var rigidBody = object.getTrait(RigidBody);
                                if (rigidBody != null) {
                                    object.transform.buildMatrix();
                                    rigidBody.syncTransform();
                                }
                            }
                            object.visible = true;
                        }, spawnChildren);

                        if (object == null) return return_bool;
                        if (object.properties == null) object.properties = new Map();
                        object.properties.set("parent",beam);
                        arr_all_arrows.push(object);
                        arrayofBeam.push(object);

					}
                    else{
                        var object: Object = arrayofBeam[j];
                        object.transform.setMatrix(matrix);

                        var rigidBody = object.getTrait(RigidBody);
                        if (rigidBody != null){rigidBody.syncTransform();
                        }
                    }
                }

                beam.properties.set(arrName_subobjects,arrayofBeam);   
			}
			
            // Error Correction
            while (arr_all_arrows.length>arrow_num_total){
                for (arrow in arr_all_arrows){
					
					if (arrow == null) return return_bool;
					if (arrow.properties == null) arrow.properties = new Map();
                    var parent: Object = arrow.properties.get("parent");
                    if (arr_beams.indexOf(parent) == -1){
                        arrow.remove();
                        arr_all_arrows.remove(arrow);
                    }
                    else if (parent == null) {
                        arrow.remove();
                        arr_all_arrows.remove(arrow);
                    }
                    else {
                        if (parent.properties == null) parent.properties = new Map();
                        var arrayofBeam: Array<Object> = parent.properties.get(arrName_subobjects);
                        if (arrayofBeam.indexOf(arrow) == -1){
                            arrow.remove();
                            arr_all_arrows.remove(arrow);
                        }
                    }
                } 
            }
        return return_bool;
        }    
    }        

}
