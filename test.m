%val =	 [1,2,3,2,1,7,8,9,9,8;
%	   3,2,2,3,1,7,8,9,9,8];
%appart(val,10,10);

% Main fonction
% on passe en paramètre la matrice de coordonnées ainsi que les limites du tableau 2D
function appart(matriceVal, x_max, y_max)
	lignes = size(matriceVal)(1);
	colonnes = size(matriceVal)(2);
	fctAppX = [];
	fctAppY = [];
	% on sélectionne chaque point
	for n = 1:colonnes
		% on donne un point et il adapte la matrice des fonctions d'appartenance
		[fctAppX,fctAppY] = check(fctAppX,fctAppY, matriceVal(:, n)', x_max, y_max);
	end
	disp(fctAppX);
endfunction

% afficher matrice = disp(..)

function [newFctX,newFctY] = check(fctAppX,fctAppY, coord, x_max, y_max)
	deltaUp = 2;
	deltaDown = deltaUp + 1;
	x = coord(1);
	y = coord(2);
	
	%Premier point	
	if(size(fctAppX)==0 | size(fctAppY)==0)
		% Prend en compte le débordement		
		newFctX = [max(0,x-deltaDown), max(0,x-deltaUp), min(x+deltaUp,x_max), min(x+deltaDown,x_max)];
		newFctY = [max(0,y-deltaDown), max(0,y-deltaUp), min(y+deltaUp,x_max), min(y+deltaDown,x_max)];
	else
		
		% Sinon tester si new fct appartenance ou existante à adapter
		% dimension x
		% cas ou il n'y a qu'un FAPP
		if(size(fctAppX)(1)==1)
			% Recherche si le point est déjà couvert à 100% par une FAPP
			if(x>=fctAppX(1,2) & x<=fctAppX(1,3))
				printf("ok\n");
				newFctX = fctAppX;
				newFctY = fctAppY;
				return;
			else
				% Chercher si le point est partiellement couvert et par quelle FAPP est elle est maximisée
				printf("ko\n");
			end;
		end
		newFctX = fctAppX;
		newFctY = fctAppY;
	end

endfunction



function [titi, toto] = test()
	titi = [1,2,3];
	toto = [5,6];
endfunction





