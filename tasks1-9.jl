using HorizonSideRobots
r=Robot(animate=true)
import HorizonSideRobots.move!
include("functions_for_1-9.jl")

function task1!(r::Robot) #задача 1 ДАНО: Робот находится в произвольной клетке ограниченного прямоугольного поля без 
                                          #внутренних перегородок и маркеров.
    #РЕЗУЛЬТАТ: Робот — в исходном положении в центре прямого креста из маркеров, расставленных вплоть до внешней рамки.
    for side in (Nord, Sud, West, Ost)
        n_steps = numsteps_mark_along!(r, side)
        along!(r, inverse(side), n_steps)
    end
    putmarker!(r)
end


function task2!(r::Robot) #задача 2 #ДАНО: Робот - в произвольной клетке поля (без внутренних перегородок и маркеров)
    #РЕЗУЛЬТАТ: Робот - в исходном положении, и все клетки по периметру внешней рамки промакированы
    steps_to_left_down_angle = [0, 0] # (шаги_вниз, шаги_влево)
    steps_to_left_down_angle[1] = num_steps_along!(r, Sud)
    steps_to_left_down_angle[2] = num_steps_along!(r, West)
    for side in (Nord, Ost, Sud, West)
        numsteps_mark_along!(r, side)
    end
    along!(r, Ost, steps_to_left_down_angle[2])
    along!(r, Nord, steps_to_left_down_angle[1])
end



function task3!(r::Robot) #задача 3 #ДАНО: Робот - в произвольной клетке ограниченного прямоугольного поля
    #РЕЗУЛЬТАТ: Робот - в исходном положении, и все клетки поля промакированы
    steps_to_origin = get_left_down_angle!(r)
    putmarker!(r)
    while !isborder(r, Ost)
        numsteps_mark_along!(r,Nord)
        move!(r, Ost)
        putmarker!(r)
        numsteps_mark_along!(r, Sud)
    end
    get_left_down_angle!(r)
    get_to_origin!(r, steps_to_origin)
end


function task4!(r::Robot) #задача 4 #ДАНО: Робот находится в произвольной клетке ограниченного прямоугольного поля без 
    #внутренних перегородок и маркеров.
    #РЕЗУЛЬТАТ: Робот — в исходном положении в центре косого креста из маркеров, расставленных вплоть до внешней рамки.
    sides = (Nord, Ost, Sud, West)
    for i in 1:4
        first_side = sides[i]
        second_side = sides[i % 4 + 1]
        direction = (first_side, second_side)
        n_steps = numsteps_mark_along!(r, direction)
        along!(r, inverse(direction), n_steps)
    end
    putmarker!(r)
end


function task5!(r::Robot) #Задача 5 
 #ДАНО: На ограниченном внешней прямоугольной рамкой поле имеется ровно одна внутренняя 
    #перегородка в форме прямоугольника. Робот - в произвольной клетке поля между внешней и внутренней перегородками. 
    #РЕЗУЛЬТАТ: Робот - в исходном положении и по всему периметру внутренней, как внутренней, так и внешней, перегородки поставлены маркеры.
    
        steps = get_left_down_angle_modified!(r)
    
        while isborder(r, Sud) && !isborder(r, Ost)
            num_steps_along!(r, Nord)
            move!(r, Ost)
            while !isborder(r, Ost) && try_move!(r, Sud) end
        end
    
        for sides in [(Sud, Ost), (Ost, Nord), (Nord, West), (West, Sud)]
            side_to_move, side_to_border = sides
            while isborder(r, side_to_border)
                putmarker!(r)
                move!(r, side_to_move)
            end
            putmarker!(r)
            move!(r, side_to_border)
        end
    
        get_left_down_angle_modified!(r)
        make_way_back!(r, steps)
    end



#Задача 6
function task6a!(r::Robot) # пункт "А" робот - в произвольной клетке ограниченного прямоугольного поля, на котором  
    #могут находиться также внутренние прямоугольные перегородки (все перегородки изолированы друг от друга, прямоугольники могут вырождаться в отрезки)
    #РЕЗУЛЬТАТ: Робот - в исходном положении и A) по всему периметру внешней рамки стоят маркеры;
    path =get_left_down_angle_modified!(r)
    task2!(r)
    make_way_back!(r, path)
end


function task6b!(r::Robot) #пункт "Б" маркеры не во всех клетках периметра, а только в 4-х позициях - напротив исходного положения робота
    path =  get_left_down_angle_modified!(r)
    n_steps_to_sud = 0
    n_steps_to_west = 0
    for step in path
        if step[1] == Sud
            n_steps_to_sud += step[2]
        else
            n_steps_to_west += step[2]
        end
    end

    along!(r, Ost, n_steps_to_west)
    putmarker!(r)
    num_steps_along!(r, Ost)
    along!(r, Nord, n_steps_to_sud)
    putmarker!(r)
    get_left_down_angle_modified!(r)

    along!(r, Nord, n_steps_to_sud)
    putmarker!(r)
    num_steps_along!(r, Nord)
    along!(r, Ost, n_steps_to_west)
    putmarker!(r)
    get_left_down_angle_modified!(r)

    make_way_back!(r, path)
end

#Задача 7 #ДАНО: Робот - рядом с горизонтальной бесконечно продолжающейся 
   #в обе стороны перегородкой (под ней), в которой имеется проход шириной в одну клетку.
   #РЕЗУЛЬТАТ: Робот - в клетке под проходом
function task7!(r::Robot)
    side = Ost
    while isborder(r,Nord)==true
        putmarker!(r)
        go_by_markers(r,side)
        side=inverse(side)
    end
end



#Задача 8 ДАНО: Где-то на неограниченном со всех сторон поле без внутренних перегородок 
   #имеется единственный маркер. Робот - в произвольной клетке этого поля.
   #РЕЗУЛЬТАТ: Робот - в клетке с маркером.

   function task8!(r::Robot)
    n_steps = 1
    cur_side = Ost
    counter = 1
    while true

        if moves_if_not_marker!(r, cur_side, n_steps)
            return
        end 

        cur_side = next_side(cur_side)

        if counter % 2 == 0
            n_steps += 1
        end

        counter += 1
    end
end



#задача 9 #ДАНО: Робот - в произвольной клетке ограниченного прямоугольного поля (без внутренних перегородок)
   #РЕЗУЛЬТАТ: Робот - в исходном положении, на всем поле расставлены маркеры в шахматном порядке, причем так, 
   #чтобы в клетке с роботом находился маркер

function task9!(r::Robot)
    
    steps = get_left_down_angle!(r)
    to_mark = (steps[1] + steps[2]) % 2 == 0
    steps_to_ost_border = num_steps_along!(r, Ost)
    num_steps_along!(r, West)
    last_side = steps_to_ost_border % 2 == 1 ? Sud : Nord

    side = Nord

    while !isborder(r, Ost)
        
        while !isborder(r, side)
            if to_mark
                putmarker!(r)
            end

            move!(r, side)
            to_mark = !to_mark
        end

        if to_mark
            putmarker!(r)
        end

        move!(r, Ost)
        to_mark = !to_mark
        
        side = inverse(side)
    end

    while !isborder(r, last_side)
        
        while !isborder(r, side)
            if to_mark
                putmarker!(r)
            end

            move!(r, side)
            to_mark = !to_mark
        end

        if to_mark
            putmarker!(r)
        end

    end

    get_left_down_angle!(r)
    get_to_origin!(r, steps)
end

