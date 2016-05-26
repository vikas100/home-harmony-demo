# Home Harmony Demo
This is a fully functional demo illustrating augmented reality in both still and video mode (CBCombinedPainter) and also featuring the ability to gather colors from a photo (CBColorFinder). 

### CBCombinedPainter
CBCombinedPainter allows for both live video augmented reality and still based modifications of a photo. Its recommended operation is to first start the user in live mode CBCombinedPainter.startAugmentedReality, and then capture into still mode (CBCombinedPainter.captureToImagePainter). This allows for a seamless transition between both modes and a minimal user interface. CBCombinedPainter is a subclass of the CBImagePainter class, so it offers all of the still based methods and properties, while also allowing for moving back and forth between augmented reality and still painting.

### CBColorFinder


