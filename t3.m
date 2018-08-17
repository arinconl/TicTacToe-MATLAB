clear; clc; close all; format shortG; format compact;

%{
TODO:
    Implement Hard AI

    Also:
        RR Help Sections

    Bugs:
     [x]Alphanumeric check on custom tokens
     [x]Deuce-check on Right Diagonal (/)
     [x]Deuce-check on Left Diagonal (\)
     [ ]Check validity of 'checkBoard'
            >issues with deuce-check imply issues with board-check
%}

while(true)
    
    header();
    
    fprintf('\n\\\\Menu\n');
    fprintf(' 1: Quickplay 1P\n');
    fprintf(' 2: Quickplay 2P\n');
    %{
    %fprintf(' 3: 1Player\n');
    %fprintf(' 4: 2Player\n');
    %fprintf(' 5: Scores\n');
    %}
    fprintf(' 3: Spectate\n');
    fprintf(' 4: Random\n');
    fprintf(' 5: Custom\n');
    fprintf(' 6: Help\n');
    %fprintf(' 9: Debug\n');
    fprintf(' 0: Quit\n');
    
    choice = input(' \\Make a Selection: ');
    while ( isempty(choice) || ( length(choice) ~= 1 ) || ( choice < 0 ) || ( choice > 9 ) || ( mod(choice,1) ) )
        choice = input('Erroneous Input. Please enter another selection: ');
    end
    
    defaultSize = 3;
    defaultTokenA = 'X';
    defaultTokenB = 'O';
    
    switch choice

        case 0
            fprintf('\n\\\\Thanks for playing!\n\n');
            close all;
            clear;
            break;
        case 1
            playGame(defaultSize, defaultTokenA, defaultTokenB, 'one', 'any');
        case 2
            playGame(defaultSize, defaultTokenA, defaultTokenB, 'two', 'none');
        case 3
            playGame(defaultSize, defaultTokenA, defaultTokenB, 'none', 'any');
        case 4
            random();
        case 5
            setUpCustom();
        case 6
            help();
        case 7
            playGame(defaultSize, defaultTokenA, defaultTokenB, 'one', 'hard');
        case 9
            debug();
            break;
            
    end
    
end



%% Local Functions

function playGame(boardSize, tokenA, tokenB, mode, difficulty)

    if ( ~( strcmpi(mode, 'two') ) && ( strcmpi(difficulty, 'any') ) )
        difficulty = chooseDiff();
    end
    
    if ( strcmpi(mode, 'none') )
        botA = chooseBot(difficulty);
        botB = chooseBot(difficulty);
    elseif ( strcmpi(mode, 'one') )
        botA = 0;
        botB = chooseBot(difficulty);
    else
        botA = 0;
        botB = 0;
    end
    
    % Board Data
    minTurns = boardSize + ( boardSize-1 );     % Minimum number of turns to win

    % Initialize Board
    board = zeros(1, boardSize^2);              % Initializes as an array of 1xn^2 elements
    
    close all;
    figure('menu','none','position',[200 200 500 500]);
    
    turn = 1;
    while(true)
        
        clc;

        printBoard(board, boardSize, tokenA, tokenB);
        
        % Pick Player
        if ( mod(turn, 2) )
            % Player A
            fprintf('Player One\n');
            token = +1;
            
            if ~( strcmpi(mode, 'none') )
                move = makeMove(board, boardSize, 'human', token);
            else
                move = makeMove(board, boardSize, botA, token);
            end
        else
            % Player B
            fprintf('Player Two\n');
            token = -1;
            
            if ~( strcmpi(mode, 'two') )
                move = makeMove(board, boardSize, botB, token);
            else
                move = makeMove(board, boardSize, 'human', token);
            end
        end
    
        % Make Move
        board(move) = token;

        % Pause For Spectator
        if ( strcmpi(mode, 'none') )
            pause( pi/exp( (1/3)*boardSize ));
        end
        
        % Check for Win
        if ( turn >= minTurns )                 % Only if a Win is possible
            result = checkBoard(board, boardSize, turn);
            if ( result ~= 0 )
                endGame(board, boardSize, tokenA, tokenB, result);
                break;
            end
        end
        turn = turn + 1;
        
    end
    
end



%% Menu Functions

function header()
    fprintf('\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\n')
    fprintf(' Welcome to Tic-Tac-Toe\n')
    fprintf('\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\n')
end

function random()

    clc;
    
    alphanumerics = [ 'A':'Z', 'a':'z', '0':'9' ];
    
    fprintf('\\\\Here you can set up a game with random size, tokens and difficulty.\n');

    mode = input('  How many human players will there be (two, one, none)? ','s');
    while ( ( isempty(mode) ) || ( ~any( [ strcmpi(mode, 'two'), strcmpi(mode, 'one'), strcmpi(mode, 'none') ] ) ) )
        fprintf('  Erroneous Input. Please choose from the following: two, one, none.\n');
        mode = input('  Please enter the number of human players: ','s');
    end
    
    size = randi(6);
    tokenA = alphanumerics(randi(length(alphanumerics)));
    tokenB = alphanumerics(randi(length(alphanumerics)));
    while ( strcmp(tokenA, tokenB) )
        tokenB = alphanumerics(randi(length(alphanumerics)));
    end
    
    playGame(size, tokenA, tokenB, mode, 'any')

end

function setUpCustom()

    clc;
    
    alphanumerics = [ 'A':'Z', 'a':'z', '0':'9' ];
    
    fprintf('\\\\Here you can set up size and tokens for either a human or bot game.\n');
    
    size = input('  What size n would you like the board to be? ');
    while ( ( isempty(size) ) || ( size < 1 ) || ( size > 10 ) || ( mod(size,1) ) )
        fprintf('  Erroneous Input. Size must be a positive integer value.\n');
        size = input('  Please enter another size: ');
    end
    
    tokenA = input('  What would you like for Player One''s token? ','s');
    while ( ( isempty(tokenA) ) || ( length(tokenA) ~= 1 ) || ~( any(tokenA == alphanumerics ) ) )
        fprintf('  Erroneous Input. Tokens must be a Single Character value (Alphanumeric).\n');
        tokenA = input('  Please enter another token: ','s');
    end
    
    tokenB = input('  What would you like for Player Two''s token? ','s');
    while ( ( isempty(tokenB) ) || ( length(tokenA) ~= 1 ) || ~( any(tokenA == alphanumerics ) ) )
        fprintf('  Erroneous Input. Tokens must be a Single Character value (Alphanumeric).\n');
        tokenB = input('  Please enter another token: ','s');
    end
    
    mode = input('  How many human players will there be (two, one, none)? ','s');
    while ( ( isempty(mode) ) || ( ~any( [ strcmpi(mode, 'two'), strcmpi(mode, 'one'), strcmpi(mode, 'none') ] ) ) )
        fprintf('  Erroneous Input. Please choose from the following: two, one, none.\n');
        mode = input('  Please enter the number of human players: ','s');
    end
    
    if ( ~( strcmpi(mode, 'two') ) )
        
        diff = input('  What difficulty would you like (easy, medium, hard, or any)? ','s');  
        while ( ( isempty(diff) ) || ( ~any( [ strcmpi(diff, 'easy'), strcmpi(diff, 'medium'), strcmpi(diff, 'hard'), strcmpi(diff, 'any') ] ) ) )
            fprintf('  Erroneous Input. Please choose from the following: easy, medium, hard, any.\n');
            diff = input('  Please enter the difficulty: ','s');
        end
        
    else
        
        diff = 'none';
        
    end
    
    playGame( size, tokenA, tokenB, mode, diff);

end

function help()

    clc;
    fprintf(' \\\\What would you like to know more about?\n');
    fprintf('  1: About\n');
    fprintf('  2: Instructions\n');
    fprintf('  3: Game Modes\n');
    fprintf('  0: Nothing\n');

    choice = input('  \\Make a Selection: ');
    while ( isempty(choice) || ( length(choice) ~= 1 ) || ( choice < 0 ) || ( choice > 9 ) || ( mod(choice,1) ) )
        choice = input('Erroneous Input. Please enter another selection: ');
    end
    
    switch choice
        case 0
        case 1
            about();
            fprintf('\n');
        case 2
            instructions();
            fprintf('\n');
        case 3
            gameModes();
            fprintf('\n');
    end

end

function about()
    fprintf('  \\\\About:\n');
    fprintf('   T3: Version 0.60\n');
    %fprintf('   Author: ARL\n');
end

function instructions()
    fprintf('  \\\\Instructions:\n   ');
    fprintf('Two players take turns at marking a 3x3 board with \n   ')
    fprintf('their tokens. The first to score 3 of their tokens \n   ')
    fprintf('horizontally, vertically, or diagonally wins. \n   ');
    fprintf('The board is numbered from left to right and then \n   ');
    fprintf('up to down. As such, the normal Tic-Tac-Toe board \n   ');
    fprintf('is enumerated as follows: \n   ');
    fprintf(' 1 | 2 | 3 \n   ---+---+---\n    4 | 5 | 6 \n   ---+---+---\n    7 | 8 | 9 \n   ');
    fprintf('Alternatively, moves may be input in matrix \n   ');
    fprintf('notation [ rowNumber colNumber ]. \n   ');
end

function gameModes()
    fprintf('  \\\\Quickplay 2P:\n   ');
    fprintf('Sets up a 2(Two) Player Tic-Tac-Toe Board, nothing fancy.\n');
end



%% Helper Functions

function printBoard(board, boardSize, tokenA, tokenB)

    % Insert Tokens
    boardTemp = '';
    for ii = 1:length(board)
        if ( board(ii) == +1 )
            boardTemp(ii) = tokenA;
        elseif ( board(ii) == -1 )
            boardTemp(ii) = tokenB;
        else
            boardTemp(ii) = ' ';
        end
    end
    
    % Insert Grid
    boardDisp = '';
    dispLength = (boardSize*4)+1;
    dispHeight = (boardSize*2)+1;
    for ii = 1:length(board)
        if ( ( mod(ii, boardSize) == 1 ) || ( boardSize == 1 ) )
            boardDisp = [ boardDisp, '+', repmat('---+', 1, boardSize), '|' ];
        end
        if ( mod(ii, 1) == 0 )
            boardDisp = [ boardDisp, ' ', boardTemp(ii), ' ', '|' ];
        end
    end
    boardDisp = [ boardDisp, '+', repmat('---+', 1, boardSize) ];
    
    % Format To Square
    boardDisp = (reshape(boardDisp, dispLength, dispHeight))';
    
    % Display
    disp(boardDisp);
    
    drawBoard(board, boardSize);

end

function drawBoard(board, boardSize)
    for ii = 1:boardSize^2
        subplot ( boardSize, boardSize, ii );
        if board(ii)
            if board(ii) == +1
                drawCross();
            elseif board(ii) == -1
                drawCircle();
            end
        else
            plot(0,0);
        end
        title(num2str(ii));
        axis([-1.5 1.5 -1.5 1.5]);
        axis square;
        set(gca,'YTick',[]);
        set(gca,'XTick',[]);
    end
end

function drawCircle()
    theta = linspace(0,2*pi);
    x = cos(theta);
    y = sin(theta);
    plot(x,y,'b-');
end

function drawCross()
    a = linspace(-1,1);
    b = -a;
    plot(a,a,'r-',a,b,'r-');
end

function d = chooseDiff()

    ranDiff = randi(3);
    switch ranDiff
        case 1
            d = 'easy';
        case 2
            d = 'medium';
        case 3
            %difficulty = 'hard';
            d = 'medium';
    end
        
end

function b = chooseBot(difficulty)
    
    if strcmpi(difficulty, 'easy')
        botNum = randi(2);
        switch botNum
            case 1
                b = 'rowBot';
            case 2
                b = 'colBot';
        end
    elseif strcmpi(difficulty, 'medium')
        botNum = randi(2);
        switch botNum
            case 1
                b = 'randBot';
            case 2
                b = 'medBot';
        end
    elseif strcmpi(difficulty, 'hard')
        b = 'hardBot';
    else
        fprintf('Error\n');
    end
    
end

function m = makeMove(board, boardSize, playerType, token)

    if ( strcmpi(playerType, 'human') )
        % Input
        m = input('Enter your move: ');
        % Verify
        while(true)
            if ( ( isempty(m) ) || length(m) > 1 )
                if( ( length(m) ~= 2 ) || ( m(1) < 1 ) || ( m(2) < 1 ) || ( m(1)*m(2) > boardSize^2 ) || ( mod(m(1),1) ) || ( mod(m(2),1) ) || board( ( ( m(1)-1 )*boardSize ) + m(2) ) )
                    m = input('Erroneous Input. Please enter another move: ');
                else
                    m = ( ( m(1)-1 )*boardSize ) + m(2);
                    break;
                end
            else
                if ( ( m < 1 ) || ( m > boardSize^2 ) || ( mod(m,1) ) || ( board(m) ) )
                    m = input('Erroneous Input. Please enter another move: ');
                else
                    break;
                end
            end
        end
    else
        % Bot Player
        if ( strcmpi(playerType, 'rowBot') )
            m = rowBot(board, boardSize);
        elseif ( strcmpi(playerType, 'colBot') )
            m = colBot(board, boardSize);
        elseif ( strcmpi(playerType, 'randBot') )
            m = randBot(board, boardSize);
        elseif ( strcmpi(playerType, 'medBot') )
            m = medBot(board, boardSize);
        elseif ( strcmpi(playerType, 'hardBot') )
            m = hardBot(board, boardSize, token);
        elseif ( strcmpi(playerType, 'fairBot') )
            %
        end
    end

end

function r = checkBoard(boardCurr, boardSize, turn)

    % Player A is represented by a +1;
    % Player B is represented by a -1;
    
    maxTurns = boardSize^2;                     % Maximum number of turns in a game

    board = (reshape(boardCurr, boardSize, boardSize))';

    % Check if Player A won
    if ( any( [ any(all(board>0)), any(all((board>0)')), isequal(eye(boardSize,boardSize),(board.*eye(boardSize,boardSize))), isequal(flip(eye(boardSize,boardSize)),(board.*flip(eye(boardSize,boardSize)))) ] ) )
        r = 1;
    % Check if Player B won
    elseif ( any( [ any(all(board<0)), any(all((board<0)')), isequal(-1*eye(boardSize,boardSize),(board.*eye(boardSize,boardSize))), isequal(-1*flip(eye(boardSize,boardSize)),(board.*flip(eye(boardSize,boardSize)))) ] ) )
        r = -1;
    % Board Filled
    elseif ( ( turn >= maxTurns ) )% && ( prod(board) ~= 0 ) )
        r = -2;
    % Deuce Will Occur
    elseif ( checkDeuce(board, boardSize, turn) )
        r = 2;
    % Continue Game
    else
        r = 0;
    end
    
end

function d = checkDeuce(boardCurr, boardSize, ~)

    board = (reshape(boardCurr, boardSize, boardSize))';
    boardA = board + 1;
    boardB = board - 1;

    % Check if Player A can win
    winA =  ( any( [ any(all(boardA>0)), any(all((boardA>0)')), isequal(eye(boardSize,boardSize),~(~(boardA.*eye(boardSize,boardSize)))), isequal(flip(eye(boardSize,boardSize)),~(~(boardA.*flip(eye(boardSize,boardSize))))) ] ) );
    % Check if Player B can win
    winB =  ( any( [ any(all(boardB<0)), any(all((boardB<0)')), isequal(-1*eye(boardSize,boardSize),-1*~(~(boardB.*eye(boardSize,boardSize)))), isequal(-1*flip(eye(boardSize,boardSize)),(-1*~(~(boardB.*flip(eye(boardSize,boardSize)))))) ] ) );
        
    if ( ~( winA || winB ) )
        d = 1;
    else
        d = 0;
    end
    

end

function endGame(board, boardSize, tokenA, tokenB, result)

    clc;
    printBoard(board, boardSize, tokenA, tokenB);            
    switch result
        case +2
            fprintf('Draw/Cats Eyes~\n\n');
        case +1
            fprintf('Player One won~\n\n');
        case 0
        case -1
            fprintf('Player Two won~\n\n');
        case -2
            fprintf('Cats Eyes/Meow~\n\n');
    end
    fprintf('\n');

end


%% Bot Players

function m = rowBot(board, ~)

    for ii = 1:length(board)
        if board(ii) == 0
            m = ii;
            break;
        end
    end
    
end

function m = colBot(board, boardSize)

    boardTemp = reshape(board, boardSize, boardSize)';
    
    for ii = 1:boardSize
        for jj = 1:boardSize
            if ( boardTemp(jj,ii) == 0 )
                m = ( ( jj-1 )*boardSize ) + ii;
                return;
            end
        end
    end

end

function m = randBot(board, boardSize)

    while(true)
        m = randi(boardSize^2);

        if ( board(m) == 0 )
            break;
        end
    end
    
end

function m = medBot(board, boardSize)

    method = randi(4);
    switch method
        case 1
            m = randBot(board, boardSize);
        case 2
            m = rowBot(board, boardSize);
        case 3
            m = colBot(board, boardSize);
        case 4
            m = randBot(board, boardSize);
    end
            
end

function m = fairBot(board, boardSize)
end

%{
function m = hardBot(board, boardSize, token)

    score = -2
    
    for ii = 1:(boardSize^2)
        if ( board(ii) == 0 )
            %Make the (ghost) move
            board(ii) = token
            %Check the (ghost) move
            tempScore = -minimax(board, boardSize, token)
            %Reset the (ghost) move
            board(ii) = 0
            %Check if move is worthwhile
            if ( tempScore > score )
                score = tempScore
                %make move
                m = ii
            end
        end
    end

end
%}



%% Atelier

function debug()
%debugging of incorrect deuce check on (/) right diagonal

    clear;clc;
    
    % TEST CASES
    boardQ = [
        +1 +1 -1 -1,...
        -1 +1 -1 +1,...
        +1  0 -1  0,...
        -1 -1 +1  0,...
        ];
    boardZ = [
        +1 +1 +1 +1 -1 +1,...
        +1 +1 -1 -1  0  0,...
        -1 -1 -1 +1  0 -1,...
        -1 -1 +1  0 -1 +1,...
         0  0 -1  0 +1  0,...
        +1  0 -1 +1 -1  0,...
        ];
    %printBoard(boardQ, 4, 'x', 'o');
    %printBoard(boardZ, 6, 'x', 'o');
    
    b = flip(boardQ);
    boardSize = 4;
    
    printBoard(b, boardSize, 'x', 'o');
    
    %{
    board = (reshape(b, boardSize, boardSize))';
    disp(board)
    disp '---'
    boardA = board + 1;
    disp(boardA)
    disp '--- (+1)'
    boardB = board - 1;
    disp(boardB)
    disp '--- (-1)'
    %}

    %{
    disp '---'
    disp(all(boardA>0))
    disp '---'
    disp(all((boardA>0)'))
    disp '---'
    disp(eye(boardSize,boardSize))
    disp '-:-'
    disp((boardA.*eye(boardSize,boardSize)))
    disp '-:-'
    disp(isequal(eye(boardSize,boardSize),(boardA.*eye(boardSize,boardSize))))
    disp '---'
    disp(flip(eye(boardSize,boardSize)))
    disp '-:-'
    disp((boardA.*flip(eye(boardSize,boardSize))))
    disp '-:-'
    disp(isequal(flip(eye(boardSize,boardSize)),~(~(boardA.*flip(eye(boardSize,boardSize))))))
    disp '---'
    %}
    
    %{
    disp(all(boardB<0))
    disp '---'
    disp(all((boardB<0)'))
    disp '---'
    disp '---'
    disp(-1*eye(boardSize,boardSize))
    disp '-:-'
    disp(boardB.*eye(boardSize,boardSize))
    disp '-:-'
    disp(isequal(-1*eye(boardSize,boardSize),(boardB.*eye(boardSize,boardSize))))
    disp '---'
    disp '---'
    disp(-1*flip(eye(boardSize,boardSize)))
    disp '-:-'
    disp(-1*~(~(boardB.*flip(eye(boardSize,boardSize)))))
    disp '-:-'
    disp( ( -1*flip(eye(boardSize,boardSize)) ) == ( boardB.*flip(eye(boardSize,boardSize)) ) )
    disp(isequal(-1*flip(eye(boardSize,boardSize)),(-1*~(~(boardB.*flip(eye(boardSize,boardSize)))))))
    disp '---'
    %}
    
    %{
    % Check if Player A can win
    winA =  ( any( [ any(all(boardA>0)), any(all((boardA>0)')), isequal(eye(boardSize,boardSize),(boardA.*eye(boardSize,boardSize))), isequal(flip(eye(boardSize,boardSize)),~(~(boardA.*flip(eye(boardSize,boardSize))))) ] ) );
    % Check if Player B can win
    winB =  ( any( [ any(all(boardB<0)), any(all((boardB<0)')), isequal(-1*eye(boardSize,boardSize),(boardB.*eye(boardSize,boardSize))), isequal(-1*flip(eye(boardSize,boardSize)),(-1*~(~(boardB.*flip(eye(boardSize,boardSize)))))) ] ) );
  
    fprintf('WinA: %d\nWinB: %d\n\n', winA, winB);
    %}
    
    fprintf('Deuce? %d\n', checkDeuce(b, boardSize));
    
    return;

end

function m = hardBot(board, boardSize, token)
    m = rowBot(board, boardSize);
end

%{
function m = hardBot(board, boardSize, token)

    moves = [];
    [ bestMove, ~ ] = getBestMove(board, boardSize, token, moves);
    m = bestMove;

end

function [ m,  s ] = getBestMove(board, boardSize, token, moves)

    fprintf('meow1\n');
    
    if isempty(moves)
        res = checkBoard(board, boardSize, boardSize^2);
        fprintf('meow2\n');
        if (res == -1)
        fprintf('meow3\n');
            s = 10
            return;
        elseif (res == 1)
        fprintf('meow4\n');
            s = -10
            return;
        elseif ( (res == 2) || (res == -2) )
        fprintf('meow5\n');
            s = 0
            return;
        end
    end

    fprintf('meow6\n');
    
    for ii = 1:boardSize^2
        
        if ~( board(ii) )
            
            m = ii;
            
            board(ii) = token
            
            fprintf('\nRecursive Call\n');
            [ ~, s ] = getBestMove(board, boardSize, -1*token, moves)
            
            moves = [ moves; m, s ];
            
            board(ii) = 0
            
        end
        
    end

    bestM = 0;
    movesLen = size(moves);
    movesLen = movesLen(1);
    
    if ( token == -1 )
        bestScore = -1E6;
        for jj = 1:movesLen
            if ( moves(movesLen, 2) > bestScore )
                bestM = jj;
                bestS = moves(movesLen, 2);
            end
        end
    else
        bestScore = +1E6;
        for jj = 1:movesLen
            if ( moves(movesLen, 2) > bestScore )
                bestM = jj;
                bestS = moves(movesLen, 2);
            end
        end
    end
    
    m = moves(bestM, 1);
    s = bestS;
    
end
%}
%{
function m = hardBot(boardCurr, boardSize, token)

    m = getBestMove(boardCurr, boardSize, token);

end

function m = getBestMove(boardCurr, boardSize, token, moves)

    boardTemp = (reshape(boardCurr, boardSize, boardSize))';

    %basecase
    rv = checkResult(boardCurr, boardSize);
    if ( rv == token)
        score = 10*token;
    elseif ( rv == token )
        score = -10*token;
    elseif ( rv == 0 )
        score = 0;
    end
    
    for ii = 1:boardSize^2
        if (boardCurr(ii) == 0)
            boardCurr(ii) = token;
            
            %getscore
            if ( token == -1 )
                score = getBestMove(boardCurr, boardSize, token, moves);
            elseif ( token == 1 )
                score = getBestMove(boardCurr, boardSize, token, moves);
            end
            
            boardCurr(ii) = 0;
            
            moves = [ moves; [ ii score ] ];
            
        end
    end
    
    bestM = 0;
    moveH = size(moves);
    if ( token == -1 )
        
        maxS = -1E6;
        maxMS = max(moveH);
        bestM = maxMS(1);
        bestS = maxMS(2);
        
    elseif ( token == 1 )
        
        maxS = +1E6;
        minMS = min(moveH);
        bestM = minMS(1);
        bestS = minMS(2);
        
    end
    
    m = bestM;
        

end

function s = minimax(board, boardSize, token)

    winner = win(board, boardSize);
    if ( winner ~= 0 )
        s = winner*token
    end
    
    s = -2
    
    for ii = 1:boardSize^2
        
        if ( board(ii) == 0 )
            board(ii) = token
            thisScore = -minimax(board, boardSize, token*-1)
            if ( thisScore > s )
                s = thisScore;
            end
            board(ii) = 0
        end
        
    end
     

end
%}


