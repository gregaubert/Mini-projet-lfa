val =	 [3,2,8.8,2,1,7,8,9,9,8;
	   3,2,8.8,3,1,7,8,9,9,8];
%appart(val,10,10);
m = rand (2,10) * 10;
n = rand(2,10) * 10 + 30;
dataset = [m(1,:), n(1,:);m(2,:),n(2,:)];

% Main fonction
% on passe en parametre la matrice de coordonnees ainsi que les limites du tableau 2D
function appart(matriceVal, x_max, y_max)
	fctAppX = [];
	fctAppY = [];
	regles = [];
<<<<<<< HEAD
	% on selectionne chaque point
	for n =1: size(matriceVal)(2)
		% on donne un point et il adapte la matrice des fonctions d'appartenance
		[fctAppX,fctAppY, regles] = checkPoint(fctAppX,fctAppY, regles, matriceVal(:, n)', x_max, y_max);
=======
	% on sélectionne chaque point
	for n = 1:colonnes
		% on donne un point et il adapte la matrice des fonctions d'appartenance
		[fctAppX,fctAppY] = checkPoint(fctAppX,fctAppY, regles, matriceVal(:, n)', x_max, y_max);
>>>>>>> 77923e180030cec991df03c6ca23a56fdad732a1
	end
	disp(fctAppX);
	disp(fctAppY);
	disp(regles);
endfunction

% afficher matrice = disp(..)

<<<<<<< HEAD
% Creer, adapte les fonctions d'appartenance par rapport au point "coord"
function [newFctX,newFctY, newRegles] = checkPoint(fctAppX,fctAppY,regles, coord, x_max, y_max)
	
=======
% Créer, adapte les fonctions d'appartenance par rapport au point "coord"
function [newFctX,newFctY] = checkPoint(fctAppX,fctAppY,regles, coord, x_max, y_max)
	% constante de base pour la création des FAPP
	deltaUp = 2;
	deltaDown = deltaUp + 1;
>>>>>>> 77923e180030cec991df03c6ca23a56fdad732a1
	
	x = coord(1);
	y = coord(2);
	
<<<<<<< HEAD
	% Traite un point selon son mu
	[newFctX, indiceAppX] = checkAppart(x, fctAppX, x_max);
	[newFctY, indiceAppY] = checkAppart(y, fctAppY, y_max);
	
	% Verifie que la regle soit active
	active = false;
	for i=1:size(regles)(1)
		if regles(i,:) == [indiceAppX, indiceAppY]
			active = true;
			break;
		endif
	endfor
	if !active
		regles = [regles ; [indiceAppX, indiceAppY]];
	endif
	newRegles = regles;
endfunction

% Traite un point
function [newFctApp, newIndice] = checkAppart(p, fctApp, p_max)
	% constante de base pour la creation des FAPP
	deltaUp = 2;
	deltaDown = deltaUp + 1;
	
	[mu, indice, c, b] = mu(p, fctApp);	
	
	% si le point n'est pas couvert : cree une nouvelle fonction d'appartenance
	if (mu < 0.1)
		vecteur = [max(0,p-deltaDown), max(0,p-deltaUp), min(p+deltaUp,p_max), min(p+deltaDown,p_max)];
		fctApp = [fctApp; vecteur];
		indice = size(fctApp)(1);
		fctApp = checkMatriceInsersion(fctApp,indice);
	% si le point est partiellement couvert : adapte la fonction d'appartenance
	elseif (0.1 <= mu && mu < 1)
		oldVector = fctApp(indice, :);
		db = p - fctApp(indice, b);
		dc = fctApp(indice, c) - p;
		fctApp(indice, b) = fctApp(indice, b) - sign(dc)*((1-mu)*dc*db);
		fctApp(indice, c) = fctApp(indice, c) - sign(dc)*(mu*dc*db);
		fctApp = checkMatriceModif(fctApp, indice, oldVector);
	% si le point est couvert : resert la fonction d'appartenance : A REVOIR
	elseif(mu == 1)
		oldVector = fctApp(indice, :);
		d1 = p - fctApp(indice, 2);
		d2 = fctApp(indice, 3) - p;
		if(abs(d1 - d2) > 0.2)
			if(d1 < d2)
				fctApp(indice, 1) = fctApp(indice, 1) + 0.02;
				fctApp(indice, 2) = fctApp(indice, 2) + 0.02;
			else
				fctApp(indice, 3) = fctApp(indice, 3) - 0.02;
				fctApp(indice, 4) = fctApp(indice, 4) - 0.02;
			endif
		endif
		fctApp = checkMatriceModif(fctApp, indice, oldVector);
	endif
	newIndice = indice;
	newFctApp = fctApp;
endfunction

function [pourcent, indice, c, b] = mu(coord, fctApp)
	pourcent = 0;
	temp = 0;
	indice = 0;
	c = 0;
	b = 0;
	for n=1:size(fctApp)(1)
		[pourcentTmp,cTmp,bTmp] = muLigne(coord, n, fctApp)
		if pourcentTmp > pourcent
			indice = n;
			pourcent = pourcentTmp;
			c = cTmp;
			b = bTmp;
		endif
	end
endfunction

function [pourcent, c, b] = muLigne(coord, ligne, fctApp)
	c=0;
	b=0;
	if(coord >= fctApp(ligne,2) && coord <= fctApp(ligne,3))
		pourcent = 1;
	elseif(coord >= fctApp(ligne, 1) && coord <= fctApp(ligne,2))
		taille = fctApp(ligne,2) - fctApp(ligne,1);
		pourcent = coord-fctApp(ligne,1)/taille;
		c = 2;
		b = 1;
	elseif(coord >= fctApp(ligne, 3) && coord <= fctApp(ligne, 4))
		l = fctApp(ligne,4) - fctApp(ligne,3);
		pourcent = 1-(coord-fctApp(ligne,3)/l);
		c = 3;
		b = 4;
	else
		pourcent = 0;
	end
endfunction

function fctApp = checkMatriceInsersion(fctApp, indice)
	delta = 0.2;
	vecteur = fctApp(indice,:);
	for i=1:size(fctApp)(1)	
		if i != indice	
			if (abs(vecteur(4) - fctApp(i,1)) <= delta)
				% Appondre \  ->\/\
				% Deplace le haut et le bas				
=======
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
>>>>>>> 77923e180030cec991df03c6ca23a56fdad732a1
				diff = fctApp(i,1) - vecteur(4);
				fctApp(indice,4) = fctApp(i,1);
				fctApp(indice,3) = fctApp(indice,3) + diff;
				
<<<<<<< HEAD
			elseif (vecteur(4) >= fctApp(i,1) && vecteur(4) <= fctApp(i,3))
				% adapter les 2 points
				fctApp(indice,4) = fctApp(i,2);
				fctApp(indice,3) = fctApp(i,1);
			endif
			if(abs(vecteur(1)-fctApp(i,4)) <= delta)
=======
			elseif (vecteur(4) >= fctApp(i,1) & vecteur(4) <= fctApp(i,3))
				% adapter les 2 points
				fctApp(indice,4) = fctApp(i,2);
				fctApp(indice,3) = fctApp(i,1);
			
			elseif(abs(vecteur(1)-fctApp(i,4)) <= delta)
>>>>>>> 77923e180030cec991df03c6ca23a56fdad732a1
				% Appondre /\/ <-   \
				diff = fctApp(i,4)-fctApp(indice,1);
				fctApp(indice,1) = fctApp(i,4);
				fctApp(indice,2) = vecteur(2) + diff;
				
<<<<<<< HEAD
			elseif(vecteur(1) >= fctApp(i,2) && vecteur(1) <= fctApp(i,4))
=======
			elseif(vecteur(1) >= fctApp(i,2) & vecteur(1) <= fctApp(i,4))
>>>>>>> 77923e180030cec991df03c6ca23a56fdad732a1
				% adapter les deux points
				fctApp(indice,1) = fctApp(i,3);
				fctApp(indice,2) = fctApp(i,4);
				
			endif
		endif
	endfor
<<<<<<< HEAD
endfunction

% Apres un changement dans une fonction d'appartenance existante, effectue une modification en chaine des autres fonctions liee
function fctApp = checkMatriceModif(fctApp, indice, old)
	v = fctApp(indice,:);
	for i=1:size(fctApp)(1)	
		if i != indice
			for j=1:size(fctApp)(2)
				if fctApp(i,j) == old(j)
					fctApp(i,j) = v(j);
				endif
			endfor
		endif
	endfor
endfunction


appart(dataset,40,40);
=======
	
end

appart(val,10,10);
>>>>>>> 77923e180030cec991df03c6ca23a56fdad732a1
