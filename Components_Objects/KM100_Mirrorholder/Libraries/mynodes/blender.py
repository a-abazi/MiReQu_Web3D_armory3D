from bpy.types import Node
from arm.logicnode.arm_nodes import *
import arm.nodes_logic

class TestNode(Node, ArmLogicTreeNode):
    '''Test node'''
    bl_idname = 'LNTestNode'
    bl_label = 'Test'
    bl_icon = 'QUESTION'

    def init(self, context):
        self.inputs.new('ArmNodeSocketAction', 'In')
        self.outputs.new('ArmNodeSocketAction', 'Out')
        
class RotateVectorAroundAxisNode(Node, ArmLogicTreeNode):
    '''Rotate object around axis node'''
    bl_idname = 'LNRotateVectorAroundAxisNode'
    bl_label = 'Rotate Vector Around Axis'
    bl_icon = 'QUESTION'

    def init(self, context):
        self.inputs.new('NodeSocketVector', 'Vector')
        self.inputs.new('NodeSocketVector', 'Axis')
        self.inputs[-1].default_value = [0, 0, 1]
        self.inputs.new('NodeSocketFloat', 'Angle')
        self.outputs.new('NodeSocketVector', 'Euler Angles')
        self.outputs.new('NodeSocketVector', 'Vector')
        self.outputs.new('NodeSocketVector', 'Quaternion XYZ')

class RotateVector(Node, ArmLogicTreeNode):
    '''Rotate object around axis node'''
    bl_idname = 'LNRotateVector'
    bl_label = 'Rotate Vector'
    bl_icon = 'QUESTION'

    def init(self, context):
        self.inputs.new('NodeSocketVector', 'Vector')
        self.inputs.new('NodeSocketVector', 'Quaternion XYZ')
        self.inputs.new('NodeSocketFloat', 'Quaternion W')
        self.outputs.new('NodeSocketVector', 'Vector')
        
class VectorAngles2D(Node, ArmLogicTreeNode):
    '''Rotate object around axis node'''
    bl_idname = 'LNVectorAngles2D'
    bl_label = 'Vector Angles 2D XY'
    bl_icon = 'QUESTION'

    def init(self, context):
        self.inputs.new('NodeSocketVector', 'Vector 1')
        self.inputs.new('NodeSocketVector', 'Vector 2')
        self.outputs.new('NodeSocketFloat', 'Angle Rad')
        self.outputs.new('NodeSocketFloat', 'Angle Deg')


class ReflectVector(Node, ArmLogicTreeNode):
    '''Rotate object around axis node'''
    bl_idname = 'LNReflectVector'
    bl_label = 'Reflect Vector at Axis'
    bl_icon = 'QUESTION'

    def init(self, context):
        self.inputs.new('NodeSocketVector', 'Vector')
        self.inputs.new('NodeSocketVector', 'Axis')
        self.inputs[-1].default_value = [0, 0, 1]
        self.outputs.new('NodeSocketVector', 'Euler Angles')
        self.outputs.new('NodeSocketVector', 'Vector')
        self.outputs.new('NodeSocketVector', 'Quaternion XYZ')

class EulerToDirectionalVector(Node, ArmLogicTreeNode):
    '''Rotate object around axis node'''
    bl_idname = 'LNEulerToDirectionalVector'
    bl_label = 'Euler Angles to directional Vector'
    bl_icon = 'QUESTION'

    def init(self, context):
        self.inputs.new('NodeSocketVector', 'Euler Angles')
        self.outputs.new('NodeSocketVector', 'Vector')

class ArrayGetIndexNode(Node, ArmLogicTreeNode):
    '''Rotate object around axis node'''
    bl_idname = 'LNArrayGetIndexNode'
    bl_label = 'Array Get Index'
    bl_icon = 'QUESTION'

    def init(self, context):        
        self.inputs.new('ArmNodeSocketArray', 'Array')
        self.inputs.new('NodeSocketShader', 'Value')
        self.outputs.new('NodeSocketInt', 'Index')

class CalculateBeamPositions(Node,ArmLogicTreeNode):
    ""
    bl_idname = "LNCalculateBeamPositions"
    bl_label = "Calculate Beam Positions"
    bl_icon = "QUESTION"

    def init(self,context):
        self.inputs.new('ArmNodeSocketAction', 'In')
        self.inputs.new("ArmNodeSocketArray","Array Beam Positions")
        self.inputs.new("ArmNodeSocketArray","Array Beam Directions")
        self.inputs.new("ArmNodeSocketArray","Array Beam Sources")
        self.inputs.new("ArmNodeSocketObject", "Source Object")
        self.inputs.new("NodeSocketString", "Trait Property Name")
        self.inputs.new("NodeSocketString", "Direction Function Name")
        self.inputs.new('NodeSocketInt', 'Interactive Filter Mask')
        self.inputs.new('NodeSocketInt', 'Max Numner of Beam Segments')

        self.outputs.new('ArmNodeSocketAction', 'Out')
        self.outputs.new("ArmNodeSocketArray","Array Beam Positions")
        self.outputs.new("ArmNodeSocketArray","Array Beam Directions")
        self.outputs.new("ArmNodeSocketArray","Array Beam Sources")
        self.outputs.new("NodeSocketBool", "Beam Blocked")

class SpawnBeams(Node,ArmLogicTreeNode):
    ""
    bl_idname = "LNSpawnBeams"
    bl_label = "Spawn Beams"
    bl_icon = "QUESTION"

    def init(self,context):
        self.inputs.new('ArmNodeSocketAction', 'In')
        self.inputs.new("ArmNodeSocketArray","Array Beam Positions")
        self.inputs.new("ArmNodeSocketArray","Array Beam Directions")
        self.inputs.new("ArmNodeSocketArray","Array Beam Sources")
        self.inputs.new("ArmNodeSocketArray","Array Beam Objects")
        self.inputs.new("NodeSocketString", "Beam Object Name")
        self.inputs.new("NodeSocketString", "Array Name Beam SubObject")
        self.inputs.new("NodeSocketString", "Component Trait Property Name")
        self.inputs.new("NodeSocketString", "GetProperties Function Name")
        self.inputs.new("NodeSocketBool", "Beam Blocked")
        self.inputs.new("NodeSocketFloat", "Beam Diameter")

        self.outputs.new('ArmNodeSocketAction', 'Out')
        self.outputs.new("ArmNodeSocketArray","Array Beam Objects")

class DespawnBeams(Node,ArmLogicTreeNode):
    ""
    bl_idname = "LNDespawnBeams"
    bl_label = "Despawn Beams"
    bl_icon = "QUESTION"

    def init(self,context):
        self.inputs.new('ArmNodeSocketAction', 'In')
        self.inputs.new("ArmNodeSocketArray","Beam Objects Array")
        self.inputs.new("NodeSocketString", "Array Name Beam SubObject")

        self.outputs.new('ArmNodeSocketAction', 'Out')        

class SpawnDespawnPol(Node,ArmLogicTreeNode):
    ""
    bl_idname = "LNSpawnDespawnPol"
    bl_label = "Spawn and Despawn Polarization Arrows"
    bl_icon = "QUESTION"

    def init(self,context):
        self.inputs.new('ArmNodeSocketAction', 'In')
        self.inputs.new("ArmNodeSocketArray","Array Beam Positions")
        self.inputs.new("ArmNodeSocketArray","Array Beam Directions")
        self.inputs.new("ArmNodeSocketArray","Array Beam Objects")
        self.inputs.new("ArmNodeSocketArray","Array All Arrows")
        self.inputs.new("NodeSocketString", "Arrow Object Name")
        self.inputs.new("NodeSocketString", "Array Name Beam SubObject")
        self.inputs.new("NodeSocketFloat", "Arrow Diameter")
        self.inputs.new("NodeSocketFloat", "Arrow Length")
        self.inputs.new("NodeSocketFloat", "Arrow Distance")
        self.inputs.new("NodeSocketInt", "Max Arrow Number")
        self.inputs.new("NodeSocketBool", "Polarization On")

        self.outputs.new('ArmNodeSocketAction', 'Out')        



def register():
    add_node(RotateVectorAroundAxisNode, category='Action')  
    add_node(ReflectVector, category='Action')      
    add_node(TestNode, category='Action')
    add_node(EulerToDirectionalVector, category='Action')
    add_node(RotateVector, category='Action')  
    add_node(VectorAngles2D, category='Action')
    add_node(ArrayGetIndexNode, category='Array')

    add_node(CalculateBeamPositions, category="Action")  
    add_node(SpawnBeams, category="Action")  
    add_node(SpawnDespawnPol, category="Action")    
    add_node(DespawnBeams, category="Action")

    arm.nodes_logic.register_nodes()
    