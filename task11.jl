using HorizonSideRobots
r=Robot(animate=true)
include("all_functions.jl")
North = Nord
South = Sud
East = Ost
function task11(r) #ДАНО: Робот - в произвольной клетке ограниченного прямоугольного поля, на поле расставлены горизонтальные перегородки различной
    # длины (перегорки длиной в несколько клеток, считаются одной перегородкой), не касающиеся внешней рамки.
    #РЕЗУЛЬТАТ: Робот — в исходном положении, подсчитано и возвращено число всех перегородок на поле.
    go_to_west_south_corner_and_return_path!(r; go_around_barriers = true)
    North = Nord
    South = Sud
    East = Ost
    my_ans = 0
    border_now = false
    side = East
    while !isborder(r, North)
        
        while !isborder(r, side)
            my_ans, border_now = find_special!(r, my_ans, border_now, North)
            move!(r,side)
        end
        my_ans, border_now = find_special!(r, my_ans, border_now, North)

        side = inverse_side(side)
        move!(r, North)
    end
    return my_ans
end

function find_special!(r::Robot, my_ans::Int, border_now::Bool, side::HorizonSide)
    if isborder(r, side)
        border_now = true
    end
    if !isborder(r, side) && border_now
        border_now = false
        my_ans += 1
    end
    return my_ans, border_now
end

function go_to_border_and_return_path!(r::Robot, side::HorizonSide; go_around_barriers::Bool = false, markers = false)::Array{Tuple{HorizonSide,Int64},1}
    my_ans = [ (North, 0) ]
    if go_around_barriers
        steps = 0
        if markers
            putmarker!(r)
        end
        if !isborder(r, side)
            move!(r, side)
            steps = 1
            push!(my_ans, (inverse_side(side), 1) )
        else
            path = go_around_barrier_and_return_path!(r, side)
            steps = get_path_length_in_direction(path, side)
            for i in path
                push!(my_ans, i)
            end
        end
        if markers
            putmarker!(r)
        end
        while steps > 0
            if !isborder(r, side)
                move!(r, side)
                steps = 1
                push!(my_ans, (inverse_side(side), 1) )
                if markers
                    putmarker!(r)
                end
            else
                path = go_around_barrier_and_return_path!(r, side)
                steps = get_path_length_in_direction(path, side)
                for i in path
                    push!(my_ans, i)
                end
                if markers
                    putmarker!(r)
                end
            end
        end

    else
        steps=0
        steps_now = go!(r,side; markers)
        while steps_now > 0
            steps += steps_now
            steps_now = go!(r,side; markers)
        end
        push!(my_ans, (inverse_side(side), steps) )
    end
    return my_ans
end


function go_to_west_south_corner_and_return_path!(r::Robot; go_around_barriers::Bool = false, markers = false)::Array{Tuple{HorizonSide,Int64},1}
    my_ans = []
    a = go_to_border_and_return_path!(r, West; go_around_barriers, markers)
    b = go_to_border_and_return_path!(r, South; go_around_barriers, markers)

    for i in a
        push!(my_ans, i)
    end
    for i in b
        push!(my_ans, i)
    end
    return my_ans
end

function inverse_side(side::HorizonSide)::HorizonSide
    return HorizonSide(mod(Int(side)+2, 4))
end

function go_around_barrier_and_return_path!(r::Robot, direct_side::HorizonSide)::Array{Tuple{HorizonSide,Int64},1}
    my_ans = []
    orthogonal_side = clockwise_side(direct_side)
    reverse_side = inverse_side(orthogonal_side)
    num_of_orthohonal_steps = 0
    num_of_direct_steps = 0

    if !isborder(r, direct_side)
        my_ans = [ (North, 0) ]
    else
        while isborder(r,direct_side) == true
            if isborder(r, orthogonal_side) == false
                move!(r, orthogonal_side)
                num_of_orthohonal_steps += 1
            else
                break
            end
        end        

        if isborder(r,direct_side) == false
            move!(r,direct_side)
            num_of_direct_steps += 1
            while isborder(r,reverse_side) == true
                num_of_direct_steps += 1
                move!(r,direct_side)
            end
            push!(my_ans, (inverse_side(orthogonal_side), num_of_orthohonal_steps) )
            push!(my_ans, (inverse_side(direct_side), num_of_direct_steps) )
            push!(my_ans, (inverse_side(reverse_side), num_of_orthohonal_steps) )
        else
            my_ans = [ (North, 0) ]
        end

        while num_of_orthohonal_steps > 0
            num_of_orthohonal_steps=num_of_orthohonal_steps-1
            move!(r,reverse_side)
        end

    end
    return my_ans
end

function clockwise_side(side::HorizonSide)::HorizonSide
    return HorizonSide(mod(Int(side)-1,4))
end