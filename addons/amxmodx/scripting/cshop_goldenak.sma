#include <amxmodx>
#include <cstrike>
#include <customshop>
#include <fakemeta>
#include <fun>
#include <hamsandwich>

#define PLUGIN_VERSION "4.x"

additem ITEM_GOLDENAK
#define GOLDENAK_ID "goldenak"
#define GOLDENAK_NAME "Golden AK47"
#define GOLDENAK_PRICE 16000
#define GOLDENAK_LIMIT 1
#define GOLDENAK_SOUND "weapons/gauss2.wav"
#define GOLDENAK_VMODEL "models/custom_shop/v_goldenak.mdl"
#define GOLDENAK_PMODEL "models/custom_shop/p_goldenak.mdl"
#define GOLDENAK_WEAPON_STR "weapon_ak47"
#define GOLDENAK_WEAPON_CSW CSW_AK47
#define GOLDENAK_DAMAGE 5
#define GOLDENAK_AMMO 500
new bool:g_blGoldenAK[33]

// Comment this line to disable the bullets.
#define USE_BULLETS

#if defined USE_BULLETS
	// You can add a shoot sound in this line, after you remove the comment.
	//#define BULLET_SOUND "weapons/ak47-1.wav"
	
	#define BULLET_MODEL "sprites/dot.spr"
	#define BULLET_STARTFRAME 1
	#define BULLET_FRAMERATE 5
	#define BULLET_LIFE 2
	#define BULLET_WIDTH 10
	#define BULLET_NOISE 0
	#define BULLET_COLOR_RED 255
	#define BULLET_COLOR_GREEN 215
	#define BULLET_COLOR_BLUE 0
	#define BULLET_BRIGHTNESS 200
	#define BULLET_SPEED 150
	new g_iGoldenBullet
#endif

#define DEFAULT_VMODEL "models/v_ak47.mdl"
#define DEFAULT_PMODEL "models/p_ak47.mdl"

public plugin_init()
{
	register_plugin("Custom Shop: Golden AK47", PLUGIN_VERSION, "OciXCrom")
	RegisterHam(Ham_TakeDamage, "player", "eventTakeDamage")
	register_event("CurWeapon", "goldenModel", "be", "1=1")
	
	#if defined USE_BULLETS
		RegisterHam(Ham_Weapon_PrimaryAttack, GOLDENAK_WEAPON_STR, "eventPrimaryAttack", 1)
	#endif
}

public plugin_precache()
{
	ITEM_GOLDENAK = cshopRegisterItem(GOLDENAK_ID, GOLDENAK_NAME, GOLDENAK_PRICE, GOLDENAK_LIMIT)
	precache_model(GOLDENAK_VMODEL)
	precache_model(GOLDENAK_PMODEL)
	
	#if defined USE_BULLETS
		g_iGoldenBullet = precache_model(BULLET_MODEL)
	#endif
	
	#if defined BULLET_SOUND
		precache_sound(BULLET_SOUND)
	#endif
}

public cshopItemBought(id, iItem)
	if(iItem == ITEM_GOLDENAK) 			{ g_blGoldenAK[id] = true; give_item(id, GOLDENAK_WEAPON_STR); cs_set_user_bpammo(id, GOLDENAK_WEAPON_CSW, GOLDENAK_AMMO); goldenModel(id); }
	
public cshopItemRemoved(id, iItem)
	if(iItem == ITEM_GOLDENAK) 			{ g_blGoldenAK[id] = false; set_default_model(id); }
	
public eventTakeDamage(iVictim, iInflictor, iAttacker, Float:flDamage, iDamageBits)
	if(is_user_alive(iAttacker) && iAttacker != iVictim)
		if(g_blGoldenAK[iAttacker] && get_user_weapon(iAttacker) == GOLDENAK_WEAPON_CSW && iAttacker == iInflictor)
			SetHamParamFloat(4, flDamage * GOLDENAK_DAMAGE)
			
#if defined USE_BULLETS			
	public eventPrimaryAttack(iWeapon)
	{
		new id = pev(iWeapon, pev_owner)
		
		if(!g_blGoldenAK[id])
			return
			
		new iClip, iAmmo
		new iWeapon = get_user_weapon(id, iClip, iAmmo)
		
		if(!iClip || iWeapon != GOLDENAK_WEAPON_CSW)
			return
		
		#if defined BULLET_SOUND
			player_emitsound(id, BULLET_SOUND)
		#endif
		
		new iVec1[3], iVec2[3]
		get_user_origin(id, iVec1, 1)
		get_user_origin(id, iVec2, 3)
		message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
		write_byte(TE_BEAMPOINTS)
		write_coord(iVec1[0])
		write_coord(iVec1[1])
		write_coord(iVec1[2])
		write_coord(iVec2[0])
		write_coord(iVec2[1])
		write_coord(iVec2[2])
		write_short(g_iGoldenBullet)
		write_byte(BULLET_STARTFRAME)
		write_byte(BULLET_FRAMERATE)
		write_byte(BULLET_LIFE)
		write_byte(BULLET_WIDTH)
		write_byte(BULLET_NOISE)
		write_byte(BULLET_COLOR_RED)
		write_byte(BULLET_COLOR_GREEN)
		write_byte(BULLET_COLOR_BLUE)
		write_byte(BULLET_BRIGHTNESS)
		write_byte(BULLET_SPEED)
		message_end()
	}
#endif

public goldenModel(id)
{
	if(get_user_weapon(id) == GOLDENAK_WEAPON_CSW && g_blGoldenAK[id])
	{
		set_pev(id, pev_viewmodel2, GOLDENAK_VMODEL)
		set_pev(id, pev_weaponmodel2, GOLDENAK_PMODEL)
	}
}

set_default_model(id)
{
	if(get_user_weapon(id) == GOLDENAK_WEAPON_CSW)
	{
		set_pev(id, pev_viewmodel2, DEFAULT_VMODEL)
		set_pev(id, pev_weaponmodel2, DEFAULT_PMODEL)
	}
}

#if defined BULLET_SOUND
	player_emitsound(id, szSound[])
		emit_sound(id, CHAN_WEAPON, szSound, 1.0, ATTN_NORM, 0, PITCH_HIGH)
#endif