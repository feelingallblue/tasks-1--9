using HorizonSideRobots
r=Robot(animate=true)
import HorizonSideRobots.move!
include("all_functions.jl")

#15. Решить задачу 7 с использованием обобщённой функции 
`shatl!(stop_condition::Function, robot)`
function task15(r::Robot, side_to_wall::HorizonSide)
    n_steps = 1
    side = next_side(side_to_wall)

    while isborder(r, side_to_wall)
        for _ in 1:n_steps
            shatl!( _ -> !isborder(r, side_to_wall), r, side)
        end
        side = inverse_side(side)
        n_steps += 1
    end

end

#Решить задачу 8 с использованием обобщённой функции 
`spiral!(stop_condition::Function, robot)`
function find_marker!(r::Robot)
    tmp = (side::HorizonSide) -> ismarker(r)
    spiral!( tmp, r)
end

#Написать рекурсивную функцию, перемещающую робота до упора в заданном направлении.
function move_until_border_recursive!(r::Robot, side::HorizonSide)
    if !isborder(r, side)
        move!(r, side)
        move_until_border_recursive!(r, side)
    end
end

#Написать рекурсивную функцию, перемещающую робота до упора в заданном направлении, 
#ставящую возле перегородки маркер и возвращающую робота в исходное положение.
function putmarker_at_border_and_back!(robot::Robot, side::HorizonSide, n_steps::Int = 0)
    if !isborder(r, side)
        move!(r, side)
        n_steps += 1
        putmarker_at_border_and_back!(r, side, n_steps)
    else
        putmarker!(r)
        along!(robot, inverse_side(side), n_steps)
    end
end

#20. Написать рекурсивную функцию, перемещающую робота в соседнюю клеьку в заданном направлении, при этом на пути робота может 
#находиться изолированная прямолинейная перегородка конечной длины.
function get_on_through_rec!(r::Robot, side::HorizonSide, n_steps::Int = 0)
    if isborder(r, side)
        move!(r, next_side(side))
        n_steps += 1
        get_on_through_rec!(r, side, n_steps)
    else
        move!(r, side)
        along!(r, inverse_side(next_side(side)), n_steps)
    end
end

#25. Написать рекурсивную функцию, перемещающую робота в заданном направлении до упора и расставлящую маркеры в шахматном порядке, 
#a) начиная с установки маркера;
#б) начиная без установки маркера (в стартовой клетке).
#**Указание:** воспользоваться косвенной рекурсией
function mark_chess_rec!(r::Robot, side::HorizonSide, to_mark = true)
    if to_mark
        putmarker!(r)
    end

    if !isborder(r, side)
        move!(r, side)
        to_mark = !to_mark
        mark_chess_rec!(r, side, to_mark)
    end
end

#A
function mark_chess_pos!(r::Robot, side::HorizonSide)
    mark_chess_rec!(r, side)
end
#Б

function mark_chess_negative!(r)
    mark_chess_rec!(r, side, false)
end