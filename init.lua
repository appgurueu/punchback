PUNCHBACK_STEPS=5 --Punchback simulation accuracy
DEFAULT_PUNCHBACK=0.2 --Default punchback strenght in blocks - used when tool hasnt got punchback capability
PUNCHBACK_RELOAD=1 --Punchback=factor*tool punchback*time from last punch, reload is factor
PUNCHBACK_MAX=3 --beyond 3 s time from last punch there's no difference
PLAYER_SIZE=0.6 --Player collisionbox simulation size in percent, eg 0.6 means 60 percent of real size

local factor=1

minetest.register_on_punchplayer(function(player, hitter, time_from_last_punch, tool_capabilities, dir, damage)
    local orig=vector.multiply(hitter:get_look_dir(),(pcall(tool_capabilities.punchback) or DEFAULT_PUNCHBACK) * math.min(PUNCHBACK_RELOAD*time_from_last_punch,PUNCHBACK_MAX)) --Calc punchback vector * strength
    local mult=vector.divide(vector.normalize(orig),PUNCHBACK_STEPS) --Divide by steps
    local pos=player:get_pos() --Player pos
    for i=0,math.ceil(vector.length(orig)*PUNCHBACK_STEPS) do --Simulation
        local d=PLAYER_SIZE
        for _,y in pairs({-1*d,0,1*d}) do
            for _,x in pairs({-0.5*d,0,0.5*d}) do
                for _,z in pairs({-0.5*d,0,0.5*d}) do
                    local v=vector.add(vector.add(pos,{x=x,y=y,z=z}),mult)
                    local floor={x=math.floor(v.x*factor+0.5)/factor,y=math.floor(v.y*factor+0.5)/factor,z=math.floor(v.z*factor+0.5)/factor}
                    if minetest.get_node(floor).walkable then --Stop moving when colliding with solid node
                        goto overjump
                    end
                end
            end
        end
        pos=vector.add(pos,mult)
    end
    ::overjump::
    player:moveto(pos) --Actual punchback
end)
