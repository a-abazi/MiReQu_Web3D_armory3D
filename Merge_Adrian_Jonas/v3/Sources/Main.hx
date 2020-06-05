// Auto-generated
package ;
class Main {
    public static inline var projectName = 'merge_v3';
    public static inline var projectPackage = 'arm';
    public static function main() {
        iron.object.BoneAnimation.skinMaxBones = 8;
        iron.object.LightObject.cascadeCount = 4;
        iron.object.LightObject.cascadeSplitFactor = 0.800000011920929;
        armory.system.Starter.main(
            'Scene',
            0,
            true,
            true,
            true,
            1280,
            800,
            1,
            true,
            armory.renderpath.RenderPathCreator.get
        );
    }
}
