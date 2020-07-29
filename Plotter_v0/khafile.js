// Auto-generated
let project = new Project('plotter');

project.addSources('Sources');
project.addLibrary("C:/blender/ArmorySDK/armory");
project.addLibrary("C:/blender/ArmorySDK/iron");
project.addParameter('arm.Plotter');
project.addParameter("--macro keep('arm.Plotter')");
project.addParameter('armory.trait.internal.Bridge');
project.addParameter("--macro keep('armory.trait.internal.Bridge')");
project.addParameter('armory.trait.internal.DebugConsole');
project.addParameter("--macro keep('armory.trait.internal.DebugConsole')");
project.addShaders("build_plotter/compiled/Shaders/*.glsl", { noembed: false});
project.addShaders("build_plotter/compiled/Hlsl/*.glsl", { noprocessing: true, noembed: false });
project.addAssets("build_plotter/compiled/Assets/**", { notinlist: true });
project.addAssets("build_plotter/compiled/Shaders/*.arm", { notinlist: true });
project.addAssets("C:/blender/ArmorySDK/armory/Assets/brdf.png", { notinlist: true });
project.addAssets("C:/blender/ArmorySDK/armory/Assets/smaa_area.png", { notinlist: true });
project.addAssets("C:/blender/ArmorySDK/armory/Assets/smaa_search.png", { notinlist: true });
project.addShaders("C:/blender/ArmorySDK/armory/Shaders/debug_draw/**");
project.addParameter('--times');
project.addLibrary("C:/blender/ArmorySDK/lib/zui");
project.addAssets("C:/blender/ArmorySDK/armory/Assets/font_default.ttf", { notinlist: false });
project.addDefine('arm_deferred');
project.addDefine('arm_csm');
project.addDefine('arm_legacy');
project.addDefine('rp_hdr');
project.addDefine('rp_renderer=Deferred');
project.addDefine('rp_shadowmap');
project.addDefine('rp_shadowmap_cascade=1024');
project.addDefine('rp_shadowmap_cube=512');
project.addDefine('rp_background=World');
project.addDefine('rp_render_to_texture');
project.addDefine('rp_compositornodes');
project.addDefine('rp_antialiasing=SMAA');
project.addDefine('rp_supersampling=1');
project.addDefine('rp_ssgi=SSAO');
project.addDefine('arm_audio');
project.addDefine('arm_noembed');
project.addDefine('arm_soundcompress');
project.addDefine('arm_debug');
project.addDefine('arm_ui');
project.addDefine('arm_skin');
project.addDefine('arm_particles');


resolve(project);
