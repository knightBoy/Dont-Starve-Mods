require("stategraphs/commonstates")

local actionhandlers = 
{
}

local events=
{
    CommonHandlers.OnStep(),
    CommonHandlers.OnSleep(),
    CommonHandlers.OnLocomote(false,true),
    EventHandler("attacked", function(inst)
        if inst.components.health and not inst.components.health:IsDead() then
            inst.sg:GoToState("hit")
            inst.SoundEmitter:PlaySound("dontstarve/creatures/chester/hurt")
        end
    end),
    EventHandler("death", function(inst) inst.sg:GoToState("death") end),
}

local states=
{
    State{
        name = "idle",
        tags = {"idle", "canrotate"},
        
        onenter = function(inst, pushanim)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("idle_loop", true)
            inst.sg:SetTimeout(4)
        end,
        
        ontimeout = function(inst)
            if math.random() < .33 then
                inst.sg:GoToState("idle_rest")
                else
                inst.sg:GoToState("idle")
            end
        end,
        
        events=
        {
            --EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        },  
   },

    State{
        name = "idle_rest",
        tags = {"idle", "canrotate"},
        
        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("rest")
        end,

        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        },
    },

    State{
        name = "attack",
        tags = {"attack", "busy"},

        onenter = function(inst, target)
            inst.sg.statemem.target = target
            inst.Physics:Stop()
            inst.components.combat:StartAttack()
            inst.AnimState:PlayAnimation("attack", true)
            inst.sg:SetTimeout(0.5)
        end,

        timeline=
        {
            TimeEvent(1*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/chester/hurt") end),
            TimeEvent(2*FRAMES, function(inst) inst.components.combat:DoAttack(inst.sg.statemem.target) end),
        },
        ontimeout = function(inst) inst.sg:GoToState("idle") end,
        events=
        {
        },
    },

    State{
        name = "death",
        tags = {"busy"},
        
        onenter = function(inst)
            inst.components.container:Close()
            inst.components.container:DropEverything()
            inst.SoundEmitter:PlaySound("dontstarve/creatures/chester/death")
            inst.AnimState:PlayAnimation("death")
            inst.Physics:Stop()
            RemovePhysicsColliders(inst)            
        end,
    },
    State{
        name = "open",
        tags = {"busy", "open"},
        
        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("open")
        end,

        events=
        {   
            EventHandler("animover", function(inst) inst.sg:GoToState("open_idle") end ),
        },

        timeline=
        {
            TimeEvent(0*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/chester/open") end),
        },     
    },

    State{
        name = "open_idle",
        tags = {"busy", "open"},
        
        onenter = function(inst)
            inst.AnimState:PlayAnimation("idle_loop_open")
            
            if not inst.sg.mem.pant_ducking or inst.sg:InNewState() then
                inst.sg.mem.pant_ducking = 1
            end
            
        end,
        events=
        {   
            EventHandler("animover", function(inst) inst.sg:GoToState("open_idle") end ),
        },
    },

    State{
        name = "close",
        tags = {""},
        
        onenter = function(inst)
            inst.AnimState:PlayAnimation("closed")
        end,

        events=
        {   
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end ),
        },

        timeline=
        {
            TimeEvent(0*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/chester/close") end),
        },      
    },
}

CommonStates.AddWalkStates(states, {
    walktimeline = 
    {
        TimeEvent(5*FRAMES, function(inst) 
            inst.SoundEmitter:PlaySound("dontstarve/creatures/chester/boing")
            inst.components.locomotor:RunForward() 
        end),
        TimeEvent(5*FRAMES, function(inst) 
            PlayFootstep(inst)
            inst.components.locomotor:WalkForward()
        end),
    }
}, nil, true)

CommonStates.AddSimpleState(states, "hit", "hit", {"busy"})

return StateGraph("xiaohua", states, events, "idle", actionhandlers)