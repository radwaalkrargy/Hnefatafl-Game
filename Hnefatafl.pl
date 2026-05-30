% k (king), d (defender), a (attacker), e (empty).
%facts
init_board([
    [e, e, e, a, a, a, e, e, e],
    [e, e, e, e, a, e, e, e, e],
    [e, e, e, e, d, e, e, e, e],
    [a, e, e, e, d, e, e, e, a],
    [a, a, d, d, k, d, d, a, a],
    [a, e, e, e, d, e, e, e, a],
    [e, e, e, e, d, e, e, e, e],
    [e, e, e, e, a, e, e, e, e],
    [e, e, e, a, a, a, e, e, e]
]).

special_square(1, 1). 
special_square(1, 9). 
special_square(9, 1). 
special_square(9, 9). 
special_square(5, 5).

is_enemy(a, d).
is_enemy(a, k).
is_enemy(d, a).

next_player(white, black).
next_player(black, white).

belongs_to(a, black).
belongs_to(d, white).
belongs_to(k, white).

%predicates
get_piece(Board, Row, Col, P) :-
    nth1(Row, Board, RowList),
    nth1(Col, RowList, P).


path_horiz(Board, Row, Col1, Col2) :-
    Col1 < Col2, 
    Start is Col1 + 1, End is Col2 - 1,
    forall(between(Start, End, C), (get_piece(Board, Row, C, e))).
	
path_horiz(Board, Row, Col1, Col2) :-
    Col1 > Col2, 
    Start is Col2 + 1, End is Col1 - 1,
    forall(between(Start, End, C), (get_piece(Board, Row, C, e))).

path_vertic(Board, Col, Row1, Row2) :-
    Row1 < Row2, 
    Start is Row1 + 1, End is Row2 - 1,
    forall(between(Start, End, R), (get_piece(Board, R, Col, e))).
path_vertic(Board, Col, Row1, Row2) :-
    Row1 > Row2, 
    Start is Row2 + 1, End is Row1 - 1,
    forall(between(Start, End, R), (get_piece(Board, R, Col, e))).

is_val_move(Board, Row1, Col1, Row2, Col2) :-
    get_piece(Board, Row1, Col1, P),
    P \= e,
    get_piece(Board, Row2, Col2, e),
    (P \= k -> \+ special_square(Row2, Col2) ; true),
    (   (Row1 = Row2, Col1 \= Col2, path_horiz(Board, Row1, Col1, Col2))
    ;   (Col1 = Col2, Row1 \= Row2, path_vertic(Board, Col1, Row1, Row2))
    ).

%----------------------------------------------------------------------------------------------------------------------------------

display_board([]). 
display_board([H|T]) :-
    print_row(H),  
    nl,            
    display_board(T).

print_row([]). 
print_row([H|T]) :-
    write(H), write('  '),
    print_row(T).


%replace(oldList, Index, newElement, newList) 

replace([_|T], 1, NewElem, [NewElem|T]). 
replace([H|T], Index, NewElem, [H|R]) :-
    Index > 1,
    NextIndex is Index - 1,
    replace(T, NextIndex, NewElem, R).

update_board(Board, Row1, Col1, Row2, Col2 , NewBoard):-
	get_piece(Board, Row1, Col1, P),

	nth1(Row1, Board, OldRow),	
	replace(OldRow, Col1, e, NewOldRow),
	replace(Board, Row1, NewOldRow, TempBoard),

	nth1(Row2, TempBoard, NRow),
	replace(NRow, Col2, P, NewRow),
	replace(TempBoard, Row2, NewRow, NewBoard).
    

piece_move(Board, Player, Row1, Col1, Row2, Col2 , FinalBoard):-
	get_piece(Board, Row1, Col1, P),
    	P \= e,
	belongs_to(P, Player),
	is_val_move(Board, Row1, Col1, Row2, Col2),
	update_board(Board, Row1, Col1, Row2, Col2 , NewBoard),
	check_all(NewBoard, Row2, Col2, FinalBoard).


check_all(Board, Row, Col, NewBoard):-
	check_up(Board, Row, Col, B1),
	check_down(B1, Row, Col, B2),
	check_left(B2, Row, Col, B3),
	check_right(B3, Row, Col, NewBoard).


check_up(Board, Row, Col, NewBoard):-
	get_piece(Board, Row, Col, P),

	NextRow is Row - 1,
	NextRow > 0,
   	get_piece(Board, NextRow, Col, PE),

	LaterRow is Row - 2,
	LaterRow > 0,
   	get_piece(Board, LaterRow, Col, PF),

	is_enemy(P, PE),
	PE \= k,
	(P = PF ; special_square(LaterRow, Col)),

	nth1(NextRow, Board, OldRow),
    	replace(OldRow, Col, e, NewRow),
    	replace(Board, NextRow, NewRow, NewBoard).

check_up(Board, _, _, Board).

check_down(Board, Row, Col, NewBoard):-
	get_piece(Board, Row, Col, P),

	NextRow is Row + 1,
	NextRow =< 9,
   	get_piece(Board, NextRow, Col, PE),

	LaterRow is Row + 2,
	LaterRow =< 9,
   	get_piece(Board, LaterRow, Col, PF),

	is_enemy(P, PE),
	PE \= k,
	(P = PF ; special_square(LaterRow, Col)),

	nth1(NextRow, Board, OldRow),
    	replace(OldRow, Col, e, NewRow),
    	replace(Board, NextRow, NewRow, NewBoard).

check_down(Board, _, _, Board).

check_left(Board, Row, Col, NewBoard):-
	get_piece(Board, Row, Col, P),

	NextCol is Col - 1,
	NextCol > 0,
   	get_piece(Board, Row, NextCol, PE),

	LaterCol is Col - 2,
	LaterCol > 0,
   	get_piece(Board, Row, LaterCol, PF),

	is_enemy(P, PE),
	PE \= k,
	(P = PF ; special_square(Row, LaterCol)),

	nth1(Row, Board, OldRow),
    	replace(OldRow, NextCol, e, NewRow),
    	replace(Board, Row, NewRow, NewBoard).

check_left(Board, _, _, Board).

check_right(Board, Row, Col, NewBoard):-
	get_piece(Board, Row, Col, P),

	NextCol is Col + 1,
	NextCol =< 9,
   	get_piece(Board, Row, NextCol, PE),

	LaterCol is Col + 2,
	LaterCol =< 9,
   	get_piece(Board, Row, LaterCol, PF),

	is_enemy(P, PE),
	PE \= k,
	(P = PF ; special_square(Row, LaterCol)),

	nth1(Row, Board, OldRow),
    	replace(OldRow, NextCol, e, NewRow),
    	replace(Board, Row, NewRow, NewBoard).

check_right(Board, _, _, Board).

find_king(Board, Row, Col) :-
    between(1, 9, Row),
    between(1, 9, Col),
    get_piece(Board, Row, Col, k).

is_trapped(Board, Row, Col) :-
	(Row < 1 ; Row > 9 ; Col < 1 ; Col > 9), !.

is_trapped(Board, Row, Col):-
	get_piece(Board, Row, Col, a), !.

is_trapped(Board, 5, 5):-
    get_piece(Board, 5, 5, e), !.

is_trapped(Board, Row, Col):-
    special_square(Row, Col), 
    \+ (Row = 5, Col = 5).

is_king_capture(Board):-
	find_king(Board, R, C),
	Up is R - 1,
	Down is R + 1,
	Left is C - 1,
	Right is C + 1,
	is_trapped(Board, Up, C),
	is_trapped(Board, Down, C),
	is_trapped(Board, R, Left),
	is_trapped(Board, R, Right).
		
is_king_win(Board):-
	find_king(Board, R, C),
	special_square(R, C),      
	\+ (R = 5, C = 5).
	 
% controller(Board, Player, Human, Computer, Depth)
controller(Board, Player, _, _,_):-
	is_king_capture(Board), 
	write('Game Over! Attackers (Black) Win!'), !.

controller(Board, Player, _, _,_):-
	is_king_win(Board),
    	write('Game Over! Defenders (White) Win!'), !.

% the human turn
controller(Board, Player, Player, Computer , Depth):-
	display_board(Board),
	write('Your Turn: '), write(Player), nl,
    	write('Enter Source Row: '), read(R1),
    	write('Enter Source Col: '), read(C1),
   	    write('Enter Destination Row: '), read(R2),
    	write('Enter Destination Col: '), read(C2),

	(   piece_move(Board, Player, R1, C1, R2, C2, NewBoard) 
    	->   	display_board(NewBoard),
		    next_player(Player, Next_Player), 
        	controller(NewBoard, Next_Player, Player, Computer, Depth)  
    	; 	write('Invalid Move! Try again.'), nl,
        	controller(Board, Player, Player, Computer, Depth)      
   	).

%the computer turn
controller(Board, Player, Human, Player, Depth):-
     nl,write("----------(^_^)----------"), nl,
   
    write('Computer Turn :'), nl,

    alphabeta(state(Board, Player, Player), Depth, BestState, _),
	BestState = state(NewBoard, _, _),
   
    next_player(Player, NextPlayer),
    controller(NewBoard, NextPlayer, Human, Player, Depth).	

%-------------------------------------------------------------------------------------------
% utility helpers
count_remained_pieces([], _, 0).
count_remained_pieces([Row|T], PieceType, Total) :-
    count_in_row(Row, PieceType, RowCount),
    count_remained_pieces(T, PieceType, RestCount),
    Total is RowCount + RestCount.

count_in_row([], _, 0).
count_in_row([H|T], PieceType, Count) :-
    (H == PieceType -> Next = 1 ; Next = 0),
    count_in_row(T, PieceType, Rest),
    Count is Next + Rest.


my_abs(X, Y):-
    (X >= 0 -> Y is X ; Y is -X).

manhattan_distance((R1, C1), (R2, C2), D):-
    X is R1 - R2,
    Y is C1 - C2,
    my_abs(X, AX),
    my_abs(Y, AY),
    D is AX + AY.
	

nearest_corner_distance(Board, Distance):-
	find_king(Board, Row, Col),
	manhattan_distance((Row, Col), (1, 1), D1),
	manhattan_distance((Row, Col), (1, 9), D2),
	manhattan_distance((Row, Col), (9, 1), D3),
	manhattan_distance((Row, Col), (9, 9), D4),
	Distance is min(D1, min(D2, min(D3, D4))).

nearest_attacker_dist(Board, AttackerDist):-
	find_king(Board, R1, C1),
	findall(D, (between(1, 9, R), between(1, 9, C), get_piece(Board, R, C, a), 	manhattan_distance((R1, C1), (R, C), D)), Dists),
	min_list(Dists, AttackerDist).


count_surrounding_attackers(Board, Surrounders):-
	find_king(Board, R1, C1),
	Up is R1-1, Down is R1+1, Right is C1+1, Left is C1-1,
	 findall(1, (member((R, C), [(Up, C1), (Down, C1), (R1, Right), (R1, Left)]),
			between(1, 9, R), between(1, 9, C), get_piece(Board, R, C, a))
		, List),
	length(List, Surrounders).

avg_attacker_dist(Board, AvgDist) :-
    find_king(Board, KR, KC),
    findall(D, (
        between(1,9,R), between(1,9,C),
        get_piece(Board, R, C, a),
        manhattan_distance((KR,KC), (R,C), D)
    ), Dists),
    sumlist(Dists, Sum),
    length(Dists, Len),
    AvgDist is Sum / Len.
	

% utility
utility(state(Board, Player, Computer), Val):-
    (is_king_capture(Board) -> WinScore = 100000
    ;is_king_win(Board) -> WinScore = -100000
    ;
      (can_king_escape_next(Board) -> EscapeBonus = 50000 ; EscapeBonus = 0),
    count_remained_pieces(Board, a, Attackers),
    count_remained_pieces(Board, d, Defenders),
    find_king(Board, KR, KC),
    nearest_corner_distance(Board, CornerDist),
    
    Score_Pieces is (Defenders * 1000) - (Attackers * 500),
    
      Score_Corner is (CornerDist * 1000),

      (predicate_property(count_surrounding_attackers(_, _), visible) 
        -> count_surrounding_attackers(Board, Surrounders), Score_Pressure is Surrounders * 2000
        ; Score_Pressure is 0),

    get_center_penalty(KR, KC, Penalty),

    WinScore is Score_Pieces + Score_Corner + Score_Pressure + Penalty
    ),
    
    (Computer = black -> Val is -WinScore ; Val is WinScore).

can_king_escape_next(Board):-
    find_king(Board, R, C),
    is_val_move(Board, R, C, R2, C2),
    special_square(R2, C2), \+ (R2=5, C2=5).


get_center_penalty(5, 5, -5000) :- !.
get_center_penalty(_, _, 0).



% for computer, what are all possible positions to move to?
generate_moves(Board, Player, Moves):-
    findall(move(R1, C1, R2, C2), 
            (find_king(Board, R1, C1), belongs_to(k, Player), 
             between(1,9,R2), between(1,9,C2), is_val_move(Board, R1, C1, R2, C2),
             special_square(R2, C2), \+ (R2=5, C2=5)), 
            WinningMoves),

    findall(move(R1, C1, R2, C2), 
            (find_king(Board, R1, C1), belongs_to(k, Player), 
             between(1,9,R2), between(1,9,C2), is_val_move(Board, R1, C1, R2, C2),
             \+ special_square(R2, C2)), 
            KingEscapeMoves),

  findall(move(R1, C1, R2, C2), 
            (between(1, 9, R1), between(1, 9, C1), get_piece(Board, R1, C1, P), 
             P \= k, belongs_to(P, Player), 
             between(1, 9, R2), between(1, 9, C2), is_val_move(Board, R1, C1, R2, C2)), 
            OtherMoves),

    append(WinningMoves, KingEscapeMoves, TempMoves),
    append(TempMoves, OtherMoves, Moves).



% all possible board states after every possible move to compare and get the best one
next_state(state(Board, Player, Computer), state(NewBoard, NextPlayer, Computer)):-
    generate_moves(Board, Player, AllMoves),
    member(move(R1, C1, R2, C2), AllMoves), 
    piece_move(Board, Player, R1, C1, R2, C2, NewBoard),
    next_player(Player, NextPlayer).


% Computer is Max (we evaluate from its perspective)
isMaxPlayer(state(_, Player, Computer)) :- Player = Computer.

start :-
    init_board(B),
    write('Choose your role (black/white): '), read(Human),

    write('Choose difficulty (easy/medium/hard): '), read(Level),
    difficulty_depth(Level, Depth),

    next_player(Human, Computer),
    controller(B, black, Human, Computer, Depth).
%---------------------alphabeta----------------------------------------------------------------------
difficulty_depth(easy, 1).
difficulty_depth(medium, 2).
difficulty_depth(hard, 3).


% main entry
alphabeta(Pos, Depth, BestNextPos, Val):-
    alphabeta(Pos, Depth, -10000, 10000, BestNextPos, Val).


%---------------------- MAIN ----------------------

alphabeta(Pos, 0, _, _, _, Val) :- !, utility(Pos, Val). 
alphabeta(Pos, Depth, Alpha, Beta, BestNextPos, Val) :-
    findall(NextPos, next_state(Pos, NextPos), NextPosList),
    (   NextPosList = [] 
    ->  utility(Pos, Val) 
    ;   NewDepth is Depth - 1,
        best(NextPosList, NewDepth, Alpha, Beta, BestNextPos, Val)
    ), !.


%---------------------- BEST ----------------------

best([Pos|_], _, Alpha, Beta, _, Val):-
    Beta =< Alpha, !,
    (isMaxPlayer(Pos) -> Val is Alpha ; Val is Beta).

best([Pos], Depth, Alpha, Beta, Pos, Val):-
    alphabeta(Pos, Depth, Alpha, Beta, _, Val), !.

best([Pos1|Tail], Depth, Alpha, Beta, BestPos, BestVal):-
    alphabeta(Pos1, Depth, Alpha, Beta, _, Val1),
    updateValues(Pos1, Val1, Alpha, Beta, NewAlpha, NewBeta),
    best(Tail, Depth, NewAlpha, NewBeta, Pos2, Val2),
    betterOf(Pos1, Val1, Pos2, Val2, BestPos, BestVal).


%---------------------- UPDATE VALUES ----------------------

updateValues(Pos, Value, Alpha, Beta, NewAlpha, Beta):-
    isMaxPlayer(Pos), !,
    (Value > Alpha -> NewAlpha is Value ; NewAlpha is Alpha).

updateValues(_, Value, Alpha, Beta, Alpha, NewBeta):-
    (Value < Beta -> NewBeta is Value ; NewBeta is Beta).


%---------------------- BETTER OF ----------------------

betterOf(Pos1, Val1, Pos2, Val2, BestPos, BestVal):-
    isMaxPlayer(Pos1),
    (Val1 >= Val2 ->
        (BestPos = Pos1, BestVal is Val1)
    ;
        (BestPos = Pos2, BestVal is Val2)
    ), !.

betterOf(Pos1, Val1, Pos2, Val2, BestPos, BestVal):-
    (Val1 =< Val2 ->
        (BestPos = Pos1, BestVal is Val1)
    ;
        (BestPos = Pos2, BestVal is Val2)
    ), !.