val =	 [3,2,8.8,2,1,7,8,9,9,8;
	   3,2,8.8,3,1,7,8,9,9,8];
%appart(val,10,10);

% Main fonction
% on passe en paramètre la matrice de coordonnées ainsi que les limites du tableau 2D
function appart(matriceVal, x_max, y_max)
	lignes = size(matriceVal)(1);
	colonnes = size(matriceVal)(2);
	fctAppX = [];
	fctAppY = [];
	regles = [];
	% on sélectionne chaque point
	for n = 1:colonnes
		% on donne un point et il adapte la matrice des fonctions d'appartenance
		[fctAppX,fctAppY] = checkPoint(fctAppX,fctAppY, regles, matriceVal(:, n)', x_max, y_max);
	end
	disp(fctAppX);
endfunction

% afficher matrice = disp(..)

% Créer, adapte les fonctions d'appartenance par rapport au point "coord"
function [newFctX,newFctY] = checkPoint(fctAppX,fctAppY,regles, coord, x_max, y_max)
	% constante de base pour la création des FAPP
	deltaUp = 2;
	deltaDown = deltaUp + 1;
	
	x = coord(1);
	y = coord(2);
	
	vecteurX = [];
	vecteurY = [];
	
	[muX, indiceX] = mu(x, fctAppX);
	[muY, indiceY] = mu(y, fctAppY);
	
	if (muX == 0)
		vecteurX = [max(0,x-deltaDown), max(0,x-deltaUp), min(x+deltaUp,x_max), min(x+deltaDown,x_max)];
	endif
	
	if(muY == 0)
		vecteurY = [max(0,y-deltaDown), max(0,y-deltaUp), min(y+deltaUp,x_max), min(y+deltaDown,x_max)];
	endif
	
	newFctX = [fctAppX; vecteurX];
	newFctY = [fctAppY; vecteurY];
	
	for i=1:size(fctAppX)
		newFctX = checkMatriceInsersion(newFctX,i);
	endfor

endfunction

function pourcent = muLigne(coord, ligne, fctApp)
	if(coord >= fctApp(ligne,2) & coord <= fctApp(ligne,3))
		pourcent = 1;
	elseif(coord >= fctApp(ligne, 1) & coord <= fctApp(ligne,2))
		l = fctApp(ligne,2) - fctApp(ligne,1);
		pourcent = coord-fctApp(ligne,1)/l;
	elseif(coord >= fctApp(ligne, 3) & coord <= fctApp(ligne, 4))
		l = fctApp(ligne,4) - fctApp(ligne,3);
		pourcent = 1-(coord-fctApp(ligne,3)/l);
	else
		pourcent = 0;
	end
end

function [pourcent, indice] = mu(coord, fctApp)
	pourcent = 0;
	temp = 0;
	indice = 0;
	for n=1:size(fctApp)(1)
		pourcent = max(pourcent, muLigne(coord, n, fctApp));
		if pourcent != temp 
			indice = n;
		endif
		temp = pourcent;
	end
endfunction

function fctApp = checkMatriceInsersion(fctApp, indice)
	delta = 0.2;
	vecteur = fctApp(indice,:);
	for i=1:size(fctApp)(1)	
		if i != indice	

				
			if (abs(vecteur(4) - fctApp(i,1)) <= delta)
				% Appondre /   ->\/\
				% Déplace le haut et le bas				
				diff = fctApp(i,1) - vecteur(4);
				fctApp(indice,4) = fctApp(i,1);
				fctApp(indice,3) = fctApp(indice,3) + diff;
				
			elseif (vecteur(4) >= fctApp(i,1) & vecteur(4) <= fctApp(i,3))
				% adapter les 2 points
				fctApp(indice,4) = fctApp(i,2);
				fctApp(indice,3) = fctApp(i,1);
			
			elseif(abs(vecteur(1)-fctApp(i,4)) <= delta)
				% Appondre /\/ <-   \
				diff = fctApp(i,4)-fctApp(indice,1);
				fctApp(indice,1) = fctApp(i,4);
				fctApp(indice,2) = vecteur(2) + diff;
				
			elseif(vecteur(1) >= fctApp(i,2) & vecteur(1) <= fctApp(i,4))
				% adapter les deux points
				fctApp(indice,1) = fctApp(i,3);
				fctApp(indice,2) = fctApp(i,4);
				
			endif
		endif
	endfor
	
end

appart(val,10,10);
