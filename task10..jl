using HorizonSideRobots
r=Robot(animate=true)
North = Nord
South = Sud
East = Ost
function task10(r::Robot, cell_size::Int) #ДАНО: Робот - в произвольной клетке ограниченного прямоугольного поля (без внутренних перегородок)
    #    РЕЗУЛЬТАТ: Робот - в исходном положении, и на всем поле расставлены маркеры в шахматном порядке клетками размера N*N (N-параметр функции), 
    #начиная с юго-западного угла
    North = Nord
    South = Sud
    East = Ost
    path = go_to_west_south_corner_and_return_path!(r)
    x=0; y=0
    horisontalDirection = East
    
    while !(isborder(r, Nord) && isborder(r, East))
        marker_special!(r, x, y, cell_size)
        if move_up_condition(r)
            move!(r, Nord)
            y += 1
            marker_special!(r, x, y, cell_size)
            horisontalDirection = inverse_side(horisontalDirection)
        end
        
        move!(r,horisontalDirection)
        (horisontalDirection == East) ? x += 1 : x -= 1
    end

    marker_special!(r, x, y, cell_size)

    go_to_west_south_corner_and_return_path!(r)
    go_by_path!(r, path) # возвращаемся назад
end

function marker_special!(r, x, y, cell_size)
    if (mod(x, 2 * cell_size)) < cell_size && (mod(y, 2 * cell_size)) < cell_size || 
        (mod(x + cell_size, 2 * cell_size)) < cell_size && (mod(y, 2 * cell_size)) >= cell_size
        putmarker!(r)
    end
end

function move_up_condition(r) #проверка условий
    return isborder(r, East) || isborder(r, West) && !(isborder(r, South) && isborder(r, West))
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

function go_to_border_and_return_path!(r::Robot, side::HorizonSide; go_around_barriers::Bool = false, markers = false)::Array{Tuple{HorizonSide,Int64},1}
    #Перемещает робота до границы и возвращает путь для обраного следования в виде массива пар типа (направление, количество шагов)
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

function go!(r::Robot, side::HorizonSide; steps::Int = 1, go_around_barriers::Bool = false, markers = false)::Int
    #Перемещает робота в направлении
    my_ans = 0
    if markers
        putmarker!(r)
    end
    if (go_around_barriers)
        path = around_move_return_path!(r, side; steps, markers)
        my_ans = get_path_length_in_direction(path, side)
    else
        for i ∈ 1:steps

            if (markers)
                putmarker!(r)
            end

            if !isborder(r, side)
                move!(r, side)
                my_ans += 1
            else
                for i ∈ 1:my_ans
                    move!(r, inverse_side(side))
                end
                my_ans = 0
                break
            end
        end
        if (markers)
            putmarker!(r)
        end
    end

    return my_ans
end

function inverse_side(side::HorizonSide)::HorizonSide #обратная сторона
    return HorizonSide(mod(Int(side)+2, 4))
end
# возвращаемся назад
function go_by_path!(r::Robot, path::Array{Tuple{HorizonSide,Int64},1})
    new_path = reverse(path)
    for i in new_path
        go!(r, i[1]; steps = i[2])
    end
end