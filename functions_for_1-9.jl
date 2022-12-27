function inverse(side::HorizonSide)::HorizonSide #возвращает направление, противоположное заданному
    inv_side = HorizonSide((Int(side) + 2) % 4)
    return inv_side
end

function inverse(sides::NTuple{2, HorizonSide})
    new_sides = (inverse(sides[1]), inverse(sides[2]))
    return new_sides
end

function along!(r::Robot, side::HorizonSide, n_steps::Int) #перемещает робота в заданном направлении на заданное число шагов
    for i in 1:n_steps
        move!(r, side)
    end
end

function along!(r::Robot, sides::NTuple{2, HorizonSide}, n_steps::Int)
    for _ in 1:n_steps
        move!(r, sides)
    end
end

function num_steps_along!(r::Robot, side::HorizonSide)::Int #перемещает робота в заданном направлении до упора и 
    #возвращает число фактически сделанных им шагов
    n_steps = 0
    while !isborder(r, side)
        n_steps += 1
        move!(r, side)
    end
    return n_steps
end

function numsteps_mark_along!(r::Robot, side::HorizonSide)::Int #перемещает робота в заданном направлении до упора, после
    #каждого шага ставя маркер, и возвращает число фактически
    #сделанных им шагов
    n_steps = 0
    while !isborder(r, side) 
        move!(r, side)
        putmarker!(r)
        n_steps += 1
    end 
    return n_steps
end

function numsteps_mark_along!(r::Robot, sides::NTuple{2, HorizonSide})::Int
    n_steps = 0
    while !isborder(r, sides[1]) && !isborder(r, sides[2])
        n_steps += 1
        move!(r, sides)
        putmarker!(r)
    end
    return n_steps
end

function get_left_down_angle!(r::Robot)::NTuple{2, Int} # перемещает робота в нижний левый угол, возвращает количество шагов
    steps_to_left_border = num_steps_along!(r, West)
    steps_to_down_border = num_steps_along!(r, Sud)
    return (steps_to_down_border, steps_to_left_border)
end

function get_to_origin!(r::Robot, steps_to_origin::NTuple{2, Int}) #перемещает робота к исходной точке
    for (i, side) in enumerate((Nord, Ost))
        along!(r, side, steps_to_origin[i])
    end
end

function move!(r::Robot, sides::NTuple{2, HorizonSide}) 
    for side in sides
        move!(r, side)
    end
end


function try_move!(r::Robot, side::HorizonSide)::Bool #делает попытку одного шага в заданном направлении и возвращает true, 
    #в случае, если это возможно, и false - впротивном случае (робот остается в исходном положении)
    if !isborder(r, side)
        move!(r, side)
        return true
    end
    return false
end

function inversed_path(path::Vector{Tuple{HorizonSide, Int}})::Vector{Tuple{HorizonSide, Int}} #Возвращает путь после перемещения робота
    inv_path = []
    for step in path
        inv_step = (inverse(step[1]), step[2])
        push!(inv_path, inv_step)
    end
    reverse!(inv_path)
    return inv_path
end

function get_left_down_angle_modified!(r::Robot)::Vector{Tuple{HorizonSide, Int}} #в левый нижний угол
    steps = []
    while !(isborder(r, West) && isborder(r, Sud))
        steps_to_West = num_steps_along!(r, West)
        steps_to_Sud = num_steps_along!(r, Sud)
        push!(steps, (West, steps_to_West))
        push!(steps, (Sud, steps_to_Sud))
    end
    return steps
end

function next_side(side::HorizonSide)::HorizonSide #в обратную сторону
    return HorizonSide( (Int(side) + 1 ) % 4 )
end

function go_by_markers(r::Robot,side::HorizonSide) 
    while ismarker(r)==true
        move!(r,side)
    end
end



function moves_if_not_marker!(r::Robot, side::HorizonSide, n_steps::Int)::Bool 

    for _ in 1:n_steps
        if move_if_not_marker!(r, side)
            return true
        end
    end
    
    return false
end

function move_if_not_marker!(r::Robot, side::HorizonSide)::Bool #
    
    if !ismarker(r)
        move!(r, side)
        return false
    end

    return true
end

function make_way_back!(r::Robot, path::Vector{Tuple{HorizonSide, Int}}) #обратный путь
    inv_path = inversed_path(path)
    make_way!(r, inv_path)
end

function make_way!(r::Robot, path::Vector{Tuple{HorizonSide, Int}}) 
    for step in path
        along!(r, step[1], step[2])
    end
end

