local combat = Combat()
combat:setParameter(COMBAT_PARAM_TYPE, COMBAT_ICEDAMAGE)
combat:setParameter(COMBAT_PARAM_EFFECT, CONST_ME_ICETORNADO)
combat:setArea(createCombatArea(AREA_DIAMOND4X4)) 


function onCastSpell(creature, variant)
	return combat:execute(creature, variant)
 end

 
--  /*
--  Custom Area Made in Spell.lua in attempt to shape the ice tornados around the player

-- --I am unable to commenet in spells.xml but it is important that i modified that script to allow the spell to be cast
-- here is the updated line 
-- 	<instant group="attack" spellid="118" name="Seb's Attack" words="frigo" level="60" mana="0" premium="0" selftarget="1" cooldown="0" groupcooldown="0" needlearn="0" script="attack/sebs_attack.lua">
-- 		<vocation name="Druid" />
-- 		<vocation name="Elder Druid" />
-- 	</instant>

-- --- words changed to frigo to copy the video. I left the level at 60 because i made all my characters level 100. Dropped mana to 0 so i could test endlessly as well as 
-- --- changed premium to zero so i could cast the spell without a premium account.
-- */