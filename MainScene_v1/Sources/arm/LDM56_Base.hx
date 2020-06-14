package arm;
import iron.Scene;
import kha.graphics4.hxsl.Types.Vec;
import iron.math.Quat;
import iron.system.Input;
import iron.object.Object;
import iron.object.Transform;

import armory.trait.physics.RigidBody;
import armory.trait.physics.PhysicsWorld;

import iron.Trait;
import iron.math.Vec4;

import iron.math.Mat4;
import iron.math.RayCaster;

// Important!! For the movement to work, a plane object xyPlane is required as a rigidbody in group 3 (Blender: Physicsproperties/RigidBody/collections/ Blue Square in top Row and thirs cell ( left block))
// Data of UPH and Post
// 	UPH (Base+Top) has a height of 50mm(real) here 0.5m(500m)
//	Post has a heigth of 0.5m, standard position is half out, 
// Results in standard total height of 0.75m

// TODO: find out how to give an object an rigid body, and how to generate an object (so xyPlane is not needed in Blender as separate object)
// TODO: when stage is ready, stage needs to be recognized as base not platte
// TODO: multiple platten
// TODO: COnnection to object
// TODO: Collisions!!!
// TODO: (When Dynamic Meshes): Strech the post to get variables heights 
// TODO: Communicate UpdateParts to save performance, right now all components update their parts "onUpdate" of Frame
// TODO: Add Spawner
// TODO: fix translation of screws, now 


class LDM56_Base extends iron.Trait {	

	@prop 
	var plateName: String = "Platte";

	@prop 
	var mScrewName: String = "LDM56_UPH2_M_Schraube";
	@prop 
	var screwName: String = "LDM56_UPH2_Screw";
	@prop 
	var postName: String = "LDM56_UPH2_Post";
	@prop 
	var topName: String = "LDM56_UPH2_Top";
	@prop
	var laserName: String = "LDM56_Laser";

	@prop
	var defaultControls: Bool = true;

	//var children: Array <Object>;
	var nScale: Vec4  = new Vec4(0.01,0.01,0.01,1);

	var mSTravel: Float = 2.7; 			// complete travel distance of mScrew
	var mState: Int = 0; 				// different states of the screw on the base, Controls Base
						 				// 0 Locked(snaps to holes), 
						 				// 1 partially locked, rotation of base changeable, and dist between base and screw
						 				// 2 free, base translatable in loc


	var sTravel: Float = 1.5;			// complete travel distance of screw (hexScrew)
	var sState: Int = 0;	 			// different states of the screw on the Top (HexScrew), Controls Post
										// 0 Locked,
										// 1 Post can be rotated and moved up/down 


	var postDist: Float = 0.0;
	var postTrans: Float = 0.01;
	var postPosLim: Float;
	var postNegLim: Float;
	var postTravelDist: Float;

	var baseAngle: Float = -Math.PI/2;
	var baseAngleTravel: Float = Math.PI*2./100.;

	var baseDist: Float = 0.0;
	var baseTrans: Float = 0.1;
	var basePosLim: Float;
	var baseNegLim: Float;
	var baseTravelDist: Float;


	var plate: Object;
	var mScrewF: Object;
	var mScrewB: Object;
	var screwL: Object;
	var screwR: Object;
	var postL: Object;
	var postR: Object;
	var topL: Object;
	var topR: Object;
	var laser: Object;


	var zero: Vec4;
	var baseX: Vec4;
	var baseY: Vec4;

	var corrVTop: Vec4;
	var corrScrew: Vec4;
	var corrLaser: Vec4;

	var movingObj: Object = null;
	var xyPlane: Object = null;
	var hitVec: Vec4 = null;
	var planegroup: Int = 2; //third square in Blender 2^(n); n=2 (first square is n=0)

	var visib: Bool =  false;
	var mouseXmove: Float = 0;


	public function new() {
		super();
		
		notifyOnInit(onInit);
		notifyOnUpdate(onUpdate);

	};


	public function onInit() {
		initProps(object);
		var nScale: Vec4  = new Vec4(0.01,0.01,0.01,1);

		//checks if spawned by "spawner object", if not, the objects are set to be invisible
		//if (object.properties["spawned"]){
		visib = true;
		//}
		
		

		if (object.properties["baseAngle"] != null) allPropsToVariables(object);
		else allVariablesToProbs(object);

		// get base system from the plate object
		plate = Scene.active.getChild(plateName);
		zero = plate.getChildren()[2].transform.world.getLoc();
		baseX = plate.getChildren()[0].transform.world.getLoc().sub(zero);
		baseY = plate.getChildren()[1].transform.world.getLoc().sub(zero);

		// set the object to correct z stage and to the baseAngle Value(outcommented)
		object.transform.translate(0,0,zero.z -  object.getChild("C_Platte_BA2").transform.world.getLoc().z);
		object.transform.rot.fromAxisAngle(object.transform.up().normalize(), baseAngle);
		object.transform.buildMatrix();
		rbSync(object);


		//spawn the screws and setup location
		mScrewF = spawnObject(mScrewName,false);
		var mST = object.getChild("C_mScrew_Front").transform.world;
		mScrewF.transform.setMatrix(mST);
		mScrewF.transform.scale = nScale;
		mScrewF.visible = visib;
		rbSync(mScrewF);

		//  snap the screw to correct place and base, too
		var corrVxy: Vec4 = xySnapToBasis(object,mScrewF,zero,baseX,baseY);
		object.transform.translate(corrVxy.x,corrVxy.y,0);
		object.transform.buildMatrix();
		rbSync(object);
		mScrewF.transform.translate(corrVxy.x,corrVxy.y,0);
		mScrewF.transform.move(mScrewF.transform.up(), mState * mSTravel);
		rbSync(mScrewF);


		//spawn the second screw and setup location
		mScrewB = spawnObject(mScrewName,false);
		var mST = object.getChild("C_mScrew_Back").transform.world;
		mScrewB.transform.setMatrix(mST);
		mScrewB.transform.scale = nScale;
		mScrewB.visible = visib;
		rbSync(mScrewB);


		// spawn "Top" on the base, corrVTop is the correction vector concerning the location
		topL = spawnObject(topName,false);
		var mT = object.getChild("C_UPH_Left").transform.world;
		topL.transform.setMatrix(mT);
		topL.transform.scale = nScale;
		rbSync(topL);
		corrVTop = new Vec4().setFrom(topL.getChild("C_Bottom_LDM56").transform.world.getLoc()).sub(topL.transform.loc);
		topL.transform.loc.sub(corrVTop);
		topL.visible = visib;
		rbSync(topL);
		// spawn "Top" Right counterpart
		topR = spawnObject(topName,false);
		var mT = object.getChild("C_UPH_Right").transform.world;
		topR.transform.setMatrix(mT);
		topR.transform.scale = nScale;
		rbSync(topR);
		topR.transform.loc.sub(corrVTop);
		topR.visible = visib;
		rbSync(topR);

		// spawn the hex screw on the top part, see above  for corrScrew
		screwL = spawnObject(screwName,false);
		var mS = topL.getChild("C_Screw_LDM56").transform.world;
		screwL.transform.setMatrix(mS);
		screwL.transform.scale = nScale;
		rbSync(screwL);
		corrScrew = new Vec4().setFrom(screwL.getChild("C_LDM56").transform.world.getLoc()).sub(screwL.transform.loc);
		if (sState == 0)
			corrScrew.mult(0.5);

		screwL.transform.loc.sub(corrScrew);
		screwL.visible = visib;
		rbSync(screwL);

		// spawn the hex screw right counterpart
		screwR = spawnObject(screwName,false);
		var mS = topL.getChild("C_Screw_LDM56").transform.world;
		screwR.transform.setMatrix(mS);
		screwR.transform.scale = nScale;
		rbSync(screwR);
		corrScrew = new Vec4().setFrom(screwR.getChild("C_LDM56").transform.world.getLoc()).sub(screwL.transform.loc);
		if (sState == 0)
			corrScrew.mult(0.5);

		screwR.transform.loc.sub(corrScrew);
		screwR.visible = visib;
		rbSync(screwR);


		// spawn the post inside the top, with specified postDist and angle
		postL = spawnObject(postName,false);
		var mP = topL.getChild("C_Top_LDM56").transform.world;
		postL.transform.setMatrix(mP);
		postL.transform.scale = nScale;
		postL.visible = visib;
		rbSync(postL);

		// spawn the post inside the top, with specified postDist and angle
		postR = spawnObject(postName,false);
		var mP = topR.getChild("C_Top_LDM56").transform.world;
		postR.transform.setMatrix(mP);
		postR.transform.scale = nScale;
		postR.visible = visib;
		rbSync(postR);


		// measure limits from the empty child objects, limits for postTravel
		postPosLim = (postL.getChild("C_PostBottom_LDM56").transform.world.getLoc().distanceTo( topL.getChild("C_Top_LDM56").transform.world.getLoc())) + 0.01;
		postNegLim = (postL.getChild("C_PostBottom_LDM56").transform.world.getLoc().distanceTo( topL.getChild("C_Bottom_LDM56").transform.world.getLoc())+0.13); // the Float value results from the base
		postTravelDist = Math.abs(postPosLim) + Math.abs(postNegLim);
		// limits for basetravel
		// Important!! C_screw_Pos is not static and is moved around, these limits are only valid initially TODO: fix it
		basePosLim = (object.getChild("C_mScrew_Front").transform.world.getLoc().distanceTo( object.getChild("C_mScrew_Front_LimPos").transform.world.getLoc()));
		baseNegLim = (object.getChild("C_mScrew_Front").transform.world.getLoc().distanceTo( object.getChild("C_mScrew_Front_LimNeg").transform.world.getLoc())); // the Float value results from the base
		baseTravelDist = Math.abs(basePosLim) + Math.abs(baseNegLim);

		// check if supplied postDist is within limits
		if (-1*postNegLim < postDist && postDist < postPosLim){
			postL.transform.move(postL.transform.up(),postDist);
			rbSync(postL);
			postR.transform.move(postR.transform.up(),postDist);
			rbSync(postR);
		} 
		else{
			trace("Postheight not in limits");
			postDist = 0;
			rbSync(postL);
			rbSync(postR);
		}

		postDist = -0.2;
		//spawn Laser
		laser = spawnObject(laserName,false);
		var mL = postL.getChild("C_Component_LDM56").transform.world;
		laser.transform.setMatrix(mL);
		laser.transform.scale = nScale;
		rbSync(laser);		
		corrLaser = new Vec4().setFrom(laser.getChild("C_Post_Left").transform.world.getLoc()).sub(laser.transform.loc);
		laser.transform.loc.sub(corrLaser);
		laser.visible = visib;
		rbSync(laser);

		// check if supplied baseDist is within limits
		if (-1*baseNegLim < baseDist && baseDist < basePosLim){
			transBaseBy(baseDist, true);
		} 
		else{
			trace("BaseDist not in limits");
		}


		object.properties["LaserSource"] = laser.getChild("Laser_Output");
		updateParts();

	}

	// TODO: add a Boolean when screw should be locked, BUG: Snapping to other hole when in state 1, when fast mouse movement 
	function onUpdate(){
		if (!defaultControls) {
			
			return;
		}
		

		// Movement of the parts is defined by this function, as well as called functions
		var mouse = Input.getMouse();
		var keyboard = Input.getKeyboard();
		var rb = null;

		// By left click a rigid body is chosen by raytracing(part of .pickClosest) to be movingObjeckt
		// if a screw is clicked the state is switched
		if (mouse.started("left")){
			var physics = armory.trait.physics.PhysicsWorld.active;	

			rb = physics.pickClosest(mouse.x, mouse.y);
			if (rb !=null) {
				movingObj = rb.object;

				if (rb.object == mScrewF || rb.object == mScrewB  ){
					switchStateMScrew();
				}
				else if (rb.object == screwL|| rb.object == screwR){
					switchStateScrew();
				}
			}
		}
		
		// if mouse is released, variables are beeing resetted and the helping plane xyPlane is removed
		if (mouse.released("left")) {
			movingObj = null;
			if (xyPlane != null) xyPlane.remove();
			hitVec = null;
			updateParts();
		}


		// while mouse is held actions are performed for different cases of movingObj
		if (mouse.down("left") && movingObj != null ){
			
			// the post is translated by y movement of mouse in z direction, rotated by x movement
			// only if screw has correct state
			if (movingObj == postL|| movingObj == postR|| movingObj == laser) {
				var multip = 0.1;
				transPost(mouse.movementY * -1 *multip);
			}

			if ((movingObj == postL|| movingObj == postR|| movingObj == laser) && mState ==2) {
				var multip = 100;
				mouseXmove = mouseXmove + mouse.movementX;
				if (mouseXmove > 1 * multip){
					baseAngle = (baseAngle +  Math.PI/2 );
					mouseXmove = 0;
				} 
				if (mouseXmove < -1 * multip){
					baseAngle = (baseAngle -  Math.PI/2 );
					mouseXmove = 0;
				}
					
				
				allVariablesToProbs(object);
				updateParts();
			}

			// different cases for base depending on the state of screw
			// simple update if state is 0
			else if (movingObj == object && mState == 0){
				updateParts();
			}
			// for both cases an invisible xyPlane is spawned at clickheight to project mouse position in the world
			// the base is rotated according to the mouseposition and translated with fixed screw
			else if ((movingObj == object || movingObj == topL|| movingObj == topR)&& mState == 1){
				if (hitVec == null){
					hitVec = mouseToPlaneHit(mouse.x,mouse.y,1,1<<0);
					if (hitVec!=null) xyPlane = spawnXYPlane(hitVec);
				}
				var newHitVec = mouseToPlaneHit(mouse.x,mouse.y,planegroup+1,1<<planegroup);
				if (newHitVec!= null ) {
					//var dirVecNew = new Vec4().setFrom(newHitVec).sub(object.getChild("C_Screw_Pos").transform.world.getLoc());
					//var newAngle = Math.atan2(dirVecNew.y,dirVecNew.x)-Math.atan2(1,0);
					//rotBaseTo(newAngle);
					
					var distold = object.getChild("C_mScrew_Front").transform.world.getLoc().sub(hitVec).length();
					var distnew = object.getChild("C_mScrew_Front").transform.world.getLoc().sub(newHitVec).length();
					transBaseBy(distold-distnew);
					hitVec = newHitVec;
				}
				else trace("xyPlane not detected by rayCastmethod");
				
			}
			// base is translated freely according the mouse position and the other objects follow 
			else if ((movingObj == object|| movingObj == topL || movingObj == topR) && mState == 2){
				if (hitVec == null){
					hitVec = mouseToPlaneHit(mouse.x,mouse.y,1,1<<0);
					if (hitVec!=null) xyPlane = spawnXYPlane(hitVec);
				}
				
				var newHitVec = mouseToPlaneHit(mouse.x,mouse.y,planegroup+1,1<<planegroup); 
				if (newHitVec!= null && hitVec != null ) {
					var moveVec = new Vec4().setFrom(hitVec).sub(newHitVec);
					object.transform.translate(-moveVec.x,-moveVec.y ,0);
					hitVec = newHitVec;
					rbSync(object);
					updateParts();
				}
				else trace("xyPlane not detected by rayCastmethod");
			}
			
		}

	}

	function updateParts() {
		// general function that is called to update all the rigid bodys belongig to the base
		// TODO: include call to componenent on Post (e.g. Mirror), Is it needed however??
		
		allPropsToVariables(object);

		nScale = new Vec4(0.01,0.01,0.01,1); // scale parameter to change the scale of objects

		// screw (mScrew contact with plate) is updated according to C_point (Childobject )of the base
		var mST = object.getChild("C_mScrew_Front").transform.world;
		mScrewF.transform.setMatrix(mST);
		mScrewF.transform.scale = nScale;
		rbSync(mScrewF);
		// translation to indicate the state of the scre
		mScrewF.transform.move(mScrewF.transform.up(), mState * mSTravel);
		rbSync(mScrewF);

		// snapping to the correct hole of plate for correct states
		if (mState == 0 || mState ==1 ){
			var corrVxy: Vec4 = xySnapToBasis(object,mScrewF,zero,baseX,baseY);
			rbSync(object);
			mScrewF.transform.translate(corrVxy.x,corrVxy.y,0);
			rbSync(mScrewF);
	
			//object.transform.rot.fromAxisAngle(object.transform.up().normalize(), baseAngle);
			rbSync(object);
			var corrVrot = new Vec4().setFrom(object.getChild("C_mScrew_Front").transform.world.getLoc());
			corrVrot.sub(mScrewF.transform.loc);
			object.transform.translate(-1*corrVrot.x , -1*corrVrot.y , 0);
			rbSync(object);
		}

		if (mState == 2 ){
			object.transform.rot.fromAxisAngle(object.transform.up().normalize(), baseAngle);
			rbSync(object);
		}

		var mST = object.getChild("C_mScrew_Back").transform.world;
		mScrewB.transform.setMatrix(mST);
		mScrewB.transform.scale = nScale;
		rbSync(mScrewB);
		mScrewB.transform.move(mScrewB.transform.up(), mState * mSTravel);
		rbSync(mScrewB);
		

		// sync the top to the base 
		var mT = object.getChild("C_UPH_Left").transform.world;
		topL.transform.setMatrix(mT);
		topL.transform.scale = nScale;
		topL.transform.loc.sub(corrVTop);
		rbSync(topL);

		// sync the top to the base 
		var mT = object.getChild("C_UPH_Right").transform.world;
		topR.transform.setMatrix(mT);
		topR.transform.scale = nScale;
		topR.transform.loc.sub(corrVTop);
		rbSync(topR);


		// sync the hexScrew to the top part, correctional vector depends on state of screw
		var mS = topL.getChild("C_Screw_LDM56").transform.world;
		screwL.transform.setMatrix(mS);
		screwL.transform.scale = nScale;
		rbSync(screwL);
		corrScrew = new Vec4().setFrom(screwL.getChild("C_LDM56").transform.world.getLoc()).sub(screwL.transform.loc);
		if (sState == 0)
			corrScrew.mult(0.5);
		screwL.transform.loc.sub(corrScrew);
		rbSync(screwL);
		// sync the hexScrew to the top part, correctional vector depends on state of screw
		var mS = topR.getChild("C_Screw_LDM56").transform.world;
		screwR.transform.setMatrix(mS);
		screwR.transform.scale = nScale;
		rbSync(screwR);
		corrScrew = new Vec4().setFrom(screwR.getChild("C_LDM56").transform.world.getLoc()).sub(screwR.transform.loc);
		if (sState == 0)
			corrScrew.mult(0.5);
		screwR.transform.loc.sub(corrScrew);
		rbSync(screwR);


		// sync the post and translate/rotate it according to the properties
		var mP = topL.getChild("C_Top_LDM56").transform.world;
		postL.transform.setMatrix(mP);
		postL.transform.scale = nScale;
		postL.transform.move(postL.transform.up(),postDist);
		//postL.transform.rotate(postL.transform.up().normalize(),postAngle);
		rbSync(postL);

		// sync the post and translate/rotate it according to the properties
		var mP = topR.getChild("C_Top_LDM56").transform.world;
		postR.transform.setMatrix(mP);
		postR.transform.scale = nScale;
		postR.transform.move(postR.transform.up(),postDist);
		//postL.transform.rotate(postL.transform.up().normalize(),postAngle);
		rbSync(postR);

		
		var mL = postL.getChild("C_Component_LDM56").transform.world;
		laser.transform.setMatrix(mL);
		laser.transform.scale = nScale;
		rbSync(laser);
		corrLaser = new Vec4().setFrom(laser.getChild("C_Post_Left").transform.world.getLoc()).sub(laser.transform.loc);
		laser.transform.loc.sub(corrLaser);
		rbSync(laser);

		allVariablesToProbs(object);

		
	}

	function rotBase(multiplier: Float){
		// increments baseAngle by value with multiplier
		if ( mState ==1){
			baseAngle = (baseAngle + multiplier * baseAngleTravel) % (Math.PI*2);
			allVariablesToProbs(object);
			updateParts();
		}
	}

	function rotBaseTo(newAngle: Float){
		// swithces baseAngle to new angle
		if ( mState ==1 ){
			baseAngle = newAngle % (Math.PI*2);
			allVariablesToProbs(object);
			updateParts();
		}
	}

	function transBase(multiplier: Float){
		// translates base in relation to screw by increments, locked to values by the C_points 
		if (mState==1){
			multiplier = multiplier*-1;
			var scalefactor = 0.01; // factor which results due to scaling, needs to be adjusted for other scales
			if (multiplier<0){
				var baseDist = (object.getChild("C_mScrew_Front").transform.world.getLoc().distanceTo( object.getChild("C_mScrew_Front_LimNeg").transform.world.getLoc()));
				if (baseDist + multiplier*baseTrans*scalefactor>0){
					trace(baseDist);
					trace(multiplier*baseTrans);
					object.getChild("C_mScrew_Front").transform.translate(multiplier*baseTrans,0,0);
					object.getChild("C_mScrew_Back").transform.translate(multiplier*baseTrans,0,0);
					rbSync(object);
				}
			}
			else if(multiplier>0){			
				var baseDist = (object.getChild("C_mScrew_Front").transform.world.getLoc().distanceTo( object.getChild("C_mScrew_Front_LimPos").transform.world.getLoc())); 
				if (baseDist - multiplier*baseTrans*scalefactor >0){
					trace(baseDist);
					object.getChild("C_mScrew_Front").transform.translate(multiplier*baseTrans,0,0);
					object.getChild("C_mScrew_Back").transform.translate(multiplier*baseTrans,0,0);
					rbSync(object);
				}
			}
		updateParts();	
		}
	}

	function transBaseBy(dist: Float, ignoreState: Bool = false){
	// translates base in relation to screw by a value dist, locked to values by the C_points
		if (mState==1 || ignoreState){
			var scalefactor = 100; // factor which results due to scaling, needs to be adjusted for other scales#
			var baseDist = 0.;
			if (dist<0){
				baseDist = (object.getChild("C_mScrew_Front").transform.world.getLoc().distanceTo( object.getChild("C_mScrew_Front_LimNeg").transform.world.getLoc()));
			}
			else if(dist>0){			
				baseDist = (object.getChild("C_mScrew_Front").transform.world.getLoc().distanceTo( object.getChild("C_mScrew_Front_LimPos").transform.world.getLoc())); 	
			}
			if (baseDist - Math.abs(dist)>0){
				object.getChild("C_mScrew_Front").transform.translate(dist*scalefactor,0,0);
				object.getChild("C_mScrew_Back").transform.translate(dist*scalefactor,0,0);
				(object);
			}	
		allVariablesToProbs(object);
		updateParts();	
		}
	}

	

 
	function transPost(multiplier: Float){
		// translates post by increments adjusted with multiplier
		if (sState==1){
			var newPostDist = postDist + multiplier*postTrans;
			if ( newPostDist > -1*postNegLim && newPostDist< postPosLim){
					postDist = postDist + multiplier*postTrans;
				}
		allVariablesToProbs(object);
		updateParts();	
		}
	}

	function xySnapToBasis(mainObj: Object, mScrew: Object, zero: Vec4, baseX: Vec4, baseY: Vec4):Vec4 {
		// calculates a correctional vector to snap screw and base to the nearest hole of the plate object
		var sV: Vec4 = new Vec4().setFrom(mScrew.transform.loc); // initial location of screw

		sV.sub(zero);
		sV.x = sV.x % baseX.x;
		if (2 * sV.x> baseX.x) sV.x = baseX.x - sV.x;
		else sV.x = sV.x*-1;
		sV.y = sV.y % baseY.y;
		if (2 * sV.y> baseY.y) sV.y = baseY.y - sV.y;
		else sV.y = sV.y*-1;

		sV.z = 0;

		return sV;
	}
	
	function switchStateScrew() {
		// switches state of the hexScrew(connected to top, controls post movement)
		if (sState == 0){
			sState = 1;
			updateParts();
		}
		else {
			sState = 0;
			updateParts();
		}
	}

	function switchStateMScrew(){
		// switches state of MScrew, (Connected to Base, controls basemovement)
		if (mState == 0){
			mState = 1;
			updateParts();
		} 
		else if (mState == 1){
			mState = 2;
			updateParts();
		}
		else {
			mState = 0;
			updateParts();
		}
	}

	function spawnObject(objectName: String, visible: Bool):Object {
		// helping function to spawn an object
		var object: Object;
		var matrix = null;
		var spawnChildren = true;

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

		return object;
	}

	function spawnXYPlane(loc: Vec4):Object{
		// helping function to spawn invisible plane in XY
		// used to project mouse from the screen coordinates to the world
		var object: Object;
		var matrix = null;
		var spawnChildren = false;

		iron.Scene.active.spawnObject("xyPlane", null, function(o: Object) {
			object = o;
			if (matrix != null) {
				object.transform.setMatrix(matrix);
			
				var rigidBody = object.getTrait(RigidBody);
				if (rigidBody != null) {
					object.transform.buildMatrix();
					rigidBody.syncTransform();
					rigidBody.group = planegroup;
				}
			}
			object.visible = false;
		}, spawnChildren);
		//object.visible = true;
		object.transform.loc = loc;
		//trace(loc);
		//trace(object.getTrait(RigidBody).group);
		rbSync(object);
		return object;
	}

	function rbSync(object:Object) { 
		// helping function for a rigid body object, 
		// is used to align the the rigid bodys of object and children to their new parent matrix (location and rotation)
		var rigidBody = object.getTrait(RigidBody);
		if (rigidBody != null) rigidBody.syncTransform();
	}

	inline function initProps(object:Object){
		if (object == null) return;
		if (object.properties == null) object.properties = new Map();
	}

	inline function allPropsToVariables(object:Object){
		baseAngle   = object.properties["baseAngle"];
		baseDist	= object.properties["baseDist"];
		postDist	= object.properties["postDist"];
	}
	
	function allVariablesToProbs(object:Object){
		object.properties["baseAngle"] 	= baseAngle  ;
		object.properties["baseDist"] 	= baseDist;
		object.properties["postDist"] 	= postDist;
	}

	function mouseToPlaneHit (inputX, inputY,group, mask):Dynamic{
		// rayCasts mouse position according to camera to return a vector
		// modified by group and mask
		// mask is a bitwise shifted integer
		// used together with function spawnXYPlane()
		// depends on  iron.math.RayCaster
		var camera = iron.Scene.active.camera;
		var physics = armory.trait.physics.PhysicsWorld.active;
		var start = new Vec4();
		var end = new Vec4();
		RayCaster.getDirection(start, end, inputX, inputY, camera); // changes arguments end
		var hit = physics.rayCast(camera.transform.world.getLoc(), end,  group,mask);

		if (hit!=null) return new Vec4().setFrom(hit.pos);
		else return null;
	}

	function callTraitFunction(object:Object, traitNamePropertyString:String, funName: String, funArguments:Array <Dynamic>):Dynamic{
		var result: Dynamic;
		// (Small helper) This function combines some dynamic haxe functions (especially Reflect) to call 
		//  correct instance of the trait of the object. In the beginning the traitname and such are calles


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

}	