# Reactions
Activation1:
    Gdash > G1
    ka*Gdash

Activation2:
    G1 > G
    ka*G1

Transcription:
    G > G + M
    kt*G

Replication:
    G >  {2} G
    kr*G

Translation:
    M > M + P
    kf*M

DegradationG:
    G > $pool
    kG*G

DegradationM:
    M > $pool
    kM*M

DegradationP:
    P > $pool
    kP*P

# Fixed species

# Variable species
Gdash = 40
G1 = 0
G = 0
M = 0
P = 0

# Parameters
ka = 1.275
kt = 1
kr = 1
kf = 1902.7
kG = 2.8027
kM = 1.8027
kP = 0.0018027
