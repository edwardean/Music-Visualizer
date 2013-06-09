//
//  VisualizerView.m
//  iPodVisualizer
//
//  Created by Edward on 13-6-9.
//  Copyright (c) 2013年 Xinrong Guo. All rights reserved.
//

#import "VisualizerView.h"
#import <QuartzCore/QuartzCore.h>
#import "MeterTable.h"
@implementation VisualizerView {
    CAEmitterLayer *emitterLayer;
    MeterTable meterTable;
}


//1 Overrides layerClass to return CAEmitterLayer, which allows this view to act as a particle emitter.
+ (Class)layerClass {
    return [CAEmitterLayer class];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[UIColor blackColor]];
        emitterLayer = (CAEmitterLayer *)self.layer;
        
        //2 Shapes the emitter as a rectangle that extends across most of the center of the screen. Particles are initially created within this area.
        CGFloat width = MAX(frame.size.width,frame.size.height);
        CGFloat height = MIN(frame.size.width, frame.size.height);
        emitterLayer.emitterPosition = CGPointMake(width/2, height/2);
        emitterLayer.emitterSize = CGSizeMake(width-80, 60);
        emitterLayer.emitterShape = kCAEmitterLayerRectangle;
        emitterLayer.renderMode = kCAEmitterLayerAdditive;
        
        //3 Creates a CAEmitterCell that renders particles using particleTexture.png, included in the starter project.
        CAEmitterCell *cell = [CAEmitterCell emitterCell];
        cell.name = @"cell";

        CAEmitterCell *childCell = [CAEmitterCell emitterCell];
        childCell.name = @"childCell";
        childCell.lifetime = 1.0 / 60.0f;
        childCell.birthRate = 60.0f;//there will be 60 particles emitted per second
        childCell.velocity = 0.0f;
        
        childCell.contents = (id)[[UIImage imageNamed:@"particleTexture.png"] CGImage];
        cell.emitterCells = [NSArray arrayWithObject:childCell];
        
        //4 Sets the particle color, along with a range by which each of the red, green, and blue color components may vary.
        cell.color = [[UIColor colorWithRed:1.0f green:0.53f blue:0.0f alpha:0.8f] CGColor];
        cell.redRange = 0.46f;
        cell.greenRange = 0.49f;
        cell.blueRange = 0.67f;
        cell.alphaRange = 0.55f;
        
        //5 Sets the speed at which the color components change over the lifetime of the particle.
        cell.redSpeed = 0.11;
        cell.greenSpeed = 0.07f;
        cell.blueSpeed = -0.25f;
        cell.alphaSpeed = 0.15f;
        
        //6 Sets the scale and the amount by which the scale can vary for the generated particles.
        cell.scale = 0.5f;
        cell.scaleRange = 0.5f;
        
        //7 Sets the amount of time each particle will exist to between (1.0 - 0.25 =) .75 and (1.0 + 0.25 =) 1.25 seconds, and sets it to create 80 particles per second.
        cell.lifetime = 1.0f;
        cell.lifetimeRange = 0.25f;
        cell.birthRate = 80;
        
        //8 Configures the emitter to create particles with a variable velocity, and to emit them in any direction.
        cell.velocity = 100.0f;
        cell.velocityRange  =300.0f;
        cell.emissionRange = M_PI * 2;
        
        //9 Adds the emitter cell to the emitter layer.
        emitterLayer.emitterCells = [NSArray arrayWithObject:cell];
        
        // you added above creates an instance of CADisplayLink set up to call update on the target self. That means it will call the update method you just defined during each screen refresh.
        CADisplayLink *dpLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(update)];//CADisplayLink will be called for every screen update
        
        // calls addToRunLoop:forMode:, which starts the display link timer.
        [dpLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    }
    return self;
}

- (void)update {
    //1 You set scale to a default value of 0.5 and then check to see whether or not _audioPlayer is playing.
    float scale = 0.5;
    if (_audioPlayer.playing) {
        
        //2 If it is playing, you call updateMeters on _audioPlayer, which refreshes the AVAudioPlayer data based on the current audio.
        [_audioPlayer updateMeters];
         
        //3 This is the meat of the method. For each audio channel (e.g. two for a stereo file), the average power for that channel is added to power. The average power is a decibel value. After the powers of all the channels have been added together, power is divided by the number of channels. This means power now holds the average power, or decibel level, for all of the audio.
        float power = 0.0f;
        for (int i=0; i < [_audioPlayer numberOfChannels]; i++) {
            power += [_audioPlayer averagePowerForChannel:i];
        }
        power /= [_audioPlayer numberOfChannels];
        
        //4 Here you pass the calculated average power value to meterTable‘s ValueAt method. It returns a value from 0 to 1, which you multiply by 5 and then set that as the scale. Multiplying by 5 accentuates the music’s effect on the scale.
        float level = meterTable.ValueAt(power);
        scale = level * 5;
    }
    
    //5 Finally, the scale of the emitter’s particles is set to the new scale value. (If _audioPlayer was not playing, this will be the default scale of 0.5; otherwise, it will be some value based on the current audio levels.
    [emitterLayer setValue:@(scale) forKeyPath:@"emitterCells.cell.emitterCells.childCell.scale"];
}
@end
