class_name GameEnums

enum DriveType {
	HUNGER       = 0,
	THIRST       = 1,
	TIREDNESS    = 2,
	LONELINESS   = 3,
	PAIN         = 4,
	BOREDOM      = 5,
	FEAR         = 6,
	ANGER        = 7,
	SEX_DRIVE    = 8,
	BOWEL_FULL   = 9,
	MAX          = 10,
}

enum HormoneType {
	ADRENALINE   = 0,
	TESTOSTERONE = 1,
	ESTROGEN     = 2,
	SEROTONIN    = 3,
	CORTISOL     = 4,
	INSULIN      = 5,
	MELATONIN    = 6,
	OXYTOCIN     = 7,
	ENDORPHIN    = 8,
	MAX          = 9,
}

enum LobeType {
	PERCEPTION = 0,
	STIMULUS   = 1,
	CONCEPT    = 2,
	VERB       = 3,
	NOUN       = 4,
	DRIVE      = 5,
	DECISION   = 6,
	ATTENTION  = 7,
}

enum ActionType {
	IDLE         = 0,
	WALK         = 1,
	RUN          = 2,
	JUMP_UP      = 3,
	JUMP_FORWARD = 4,
	EAT          = 5,
	DRINK        = 6,
	SLEEP        = 7,
	DEFECATE     = 8,
	PUSH         = 9,
	USE          = 10,
	PICK_UP      = 11,
	DROP         = 12,
	COMMUNICATE  = 13,
	MATE         = 14,
	GIVE_BIRTH   = 15,
	MAX          = 16,
}

enum ObjectType {
	UNKNOWN    = 0,
	FOOD       = 1,
	ROCK       = 2,
	BIG_ROCK   = 3,
	POOP       = 4,
	WHEEL      = 5,
	WATER_BOWL = 6,
	BED        = 7,
	HAMSTER    = 8,
	MAX        = 9,
}

enum Sex {
	FEMALE = 0,
	MALE   = 1,
}

enum AttributeID {
	HEALTH             = 0,
	MAX_HEALTH         = 1,
	ENERGY             = 2,
	MAX_ENERGY         = 3,
	AGE                = 4,
	MAX_AGE            = 5,
	WEIGHT             = 6,
	SIZE               = 7,
	SPEED              = 8,
	MAX_SPEED          = 9,

	DRIVE_HUNGER       = 10,
	DRIVE_THIRST       = 11,
	DRIVE_TIREDNESS    = 12,
	DRIVE_LONELINESS   = 13,
	DRIVE_PAIN         = 14,
	DRIVE_BOREDOM      = 15,
	DRIVE_FEAR         = 16,
	DRIVE_ANGER        = 17,
	DRIVE_SEX_DRIVE    = 18,
	DRIVE_BOWEL_FULL   = 19,

	SEX_ATTR           = 20,
	PREGNANCY          = 21,
	GESTATION_TIMER    = 22,
	GESTATION_TIME     = 23,
	FERTILITY          = 24,

	SIGHT_RANGE        = 25,
	SMELL_RANGE        = 26,

	MAX_CARRY_WEIGHT   = 27,
	WALK_SPEED         = 28,
	RUN_SPEED          = 29,
	JUMP_FORCE         = 30,

	HAPPINESS          = 31,
	COMFORT            = 32,

	STOMACH_FULLNESS   = 33,
	STOMACH_MAX        = 34,
	INTESTINE_FULLNESS = 35,
	INTESTINE_MAX      = 36,
	DIGESTION_RATE     = 37,

	TOXIN_LEVEL        = 38,

	MAX                = 39,
}

const DRIVE_TO_ATTRIBUTE: Dictionary = {
	DriveType.HUNGER:     AttributeID.DRIVE_HUNGER,
	DriveType.THIRST:     AttributeID.DRIVE_THIRST,
	DriveType.TIREDNESS:  AttributeID.DRIVE_TIREDNESS,
	DriveType.LONELINESS: AttributeID.DRIVE_LONELINESS,
	DriveType.PAIN:       AttributeID.DRIVE_PAIN,
	DriveType.BOREDOM:    AttributeID.DRIVE_BOREDOM,
	DriveType.FEAR:       AttributeID.DRIVE_FEAR,
	DriveType.ANGER:      AttributeID.DRIVE_ANGER,
	DriveType.SEX_DRIVE:  AttributeID.DRIVE_SEX_DRIVE,
	DriveType.BOWEL_FULL: AttributeID.DRIVE_BOWEL_FULL,
}
