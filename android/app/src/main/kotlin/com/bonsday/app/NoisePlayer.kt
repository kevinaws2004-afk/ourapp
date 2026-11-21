package com.bonsday.app

import android.media.AudioAttributes
import android.media.AudioFormat
import android.media.AudioTrack
import kotlin.math.exp
import kotlin.random.Random

/// Calm background sound while focusing, made on the fly (no audio files):
/// "rain" (soft pink noise with drops), "brown" (deep rumble) or "white".
/// One at a time; play() replaces what's playing.
object NoisePlayer {
    private const val RATE = 22050
    @Volatile private var running = false
    private var thread: Thread? = null

    fun play(kind: String) {
        stop()
        running = true
        thread = Thread {
            val size = AudioTrack.getMinBufferSize(
                RATE, AudioFormat.CHANNEL_OUT_MONO, AudioFormat.ENCODING_PCM_16BIT,
            ).coerceAtLeast(4096)
            val track = AudioTrack.Builder()
                .setAudioAttributes(
                    AudioAttributes.Builder()
                        .setUsage(AudioAttributes.USAGE_MEDIA)
                        .setContentType(AudioAttributes.CONTENT_TYPE_MUSIC)
                        .build()
                )
                .setAudioFormat(
                    AudioFormat.Builder()
                        .setSampleRate(RATE)
                        .setChannelMask(AudioFormat.CHANNEL_OUT_MONO)
                        .setEncoding(AudioFormat.ENCODING_PCM_16BIT)
                        .build()
                )
                .setBufferSizeInBytes(size * 2)
                .setTransferMode(AudioTrack.MODE_STREAM)
                .build()
            val buffer = ShortArray(size / 2)
            val random = Random(System.nanoTime())
            // Filter state.
            var brown = 0.0
            var b0 = 0.0; var b1 = 0.0; var b2 = 0.0; var b3 = 0.0; var b4 = 0.0; var b5 = 0.0; var b6 = 0.0
            var drop = 0.0
            var fade = 0.0
            try {
                track.play()
                while (running) {
                    for (i in buffer.indices) {
                        val white = random.nextDouble() * 2 - 1
                        val sample = when (kind) {
                            "white" -> white * 0.25
                            "brown" -> {
                                brown = (brown + 0.02 * white) / 1.02
                                brown * 3.0
                            }
                            else -> {
                                // Pink noise (Paul Kellet), plus drops.
                                b0 = 0.99886 * b0 + white * 0.0555179
                                b1 = 0.99332 * b1 + white * 0.0750759
                                b2 = 0.96900 * b2 + white * 0.1538520
                                b3 = 0.86650 * b3 + white * 0.3104856
                                b4 = 0.55000 * b4 + white * 0.5329522
                                b5 = -0.7616 * b5 - white * 0.0168980
                                val pink = (b0 + b1 + b2 + b3 + b4 + b5 + b6 + white * 0.5362) * 0.06
                                b6 = white * 0.115926
                                if (random.nextDouble() < 0.0009) drop = 0.25 + random.nextDouble() * 0.35
                                drop *= exp(-1.0 / (RATE * 0.004))
                                pink + drop * white
                            }
                        }
                        // Fade in over the first second.
                        if (fade < 1.0) fade += 1.0 / RATE
                        buffer[i] = (sample.coerceIn(-1.0, 1.0) * fade * 26000).toInt().toShort()
                    }
                    track.write(buffer, 0, buffer.size)
                }
            } catch (_: Exception) {
            } finally {
                try { track.stop() } catch (_: Exception) {}
                track.release()
            }
        }.apply { isDaemon = true; start() }
    }

    fun stop() {
        running = false
        thread?.join(300)
        thread = null
    }
}
