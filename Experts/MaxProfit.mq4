/ / + - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - +  
 / / |                                                                                                         M a x P r o f i t . m q 4   |  
 / / |                                                                                               X a n t r u m   S o l u t i o n s .   |  
 / / |                                                                         h t t p s : / / w w w . x a n t r u m . s o l u t i o n s   |  
 / / + - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - +  
 # p r o p e r t y   d e s c r i p t i o n   " M a x   P r o f i t   E x p e r t   A d v i s o r   f o r   M e t a t r a d e r   4 "  
 # p r o p e r t y   c o p y r i g h t   " X a n t r u m   S o l u t i o n s   2 0 2 2 "  
 # p r o p e r t y   l i n k             " h t t p s : / / w w w . x a n t r u m . s o l u t i o n s "  
 # p r o p e r t y   v e r s i o n       " 1 . 7 "  
 # p r o p e r t y   i c o n               " . . / I m a g e s / M a x P r o f i t . i c o " ;    
 # p r o p e r t y   s t r i c t  
  
 # i n c l u d e   < s t d l i b . m q h >  
 # i n c l u d e   < s t d e r r o r . m q h >  
 # i n c l u d e   " . . / I n c l u d e / O r d e r s . m q h "  
 # i n c l u d e   " . . / I n c l u d e / G l o b a l _ V a r i a b l e s . m q h "  
 # i n c l u d e   " . . / I n c l u d e / h a s h _ f u n c t i o n s . m q h "  
 # i n c l u d e   " . . / I n c l u d e / M a t h _ f u n c t i o n s . m q h "  
 # i n c l u d e   " . . / I n c l u d e / T r e n d _ f u n c t i o n s . m q h "  
 # i n c l u d e   " . . / I n c l u d e / S A R _ T r e n d . m q h "  
 # i n c l u d e   " . . / I n c l u d e / M A C D _ T r e n d . m q h "  
 # i n c l u d e   " . . / I n c l u d e / S y m b o l _ f u n c t i o n s . m q h "  
 # i n c l u d e   " . . / I n c l u d e / S e c u r i t y _ f u n c t i o n s . m q h "  
 # i n c l u d e   " . . / I n c l u d e / D i s p l a y _ f u n c t i o n s . m q h "  
 # i n c l u d e   " . . / I n c l u d e / L o t _ f u n c t i o n s . m q h "  
 # i n c l u d e   " . . / I n c l u d e / G l o b a l _ f u n c t i o n s . m q h "  
 # i n c l u d e   " . . / I n c l u d e / C h e c k F o r O r d e r . m q h "  
  
 / / - - -   I n p u t s  
 e x t e r n   c o n s t   s t r i n g   E A _ P e r i o d   =   " M 1 " ;  
 e x t e r n   c o n s t   s t r i n g   D o n a t e _ P a y p a l   =   " h t t p s : / / w w w . p a y p a l . c o m / d o n a t e / ? h o s t e d _ b u t t o n _ i d = V H L 8 7 X U J E N R X Q " ;  
 b o o l   M a x i m u m _ L o t     =   f a l s e ;  
 b o o l   C o n f i r m _ O r d e r     =   f a l s e ;  
  
  
 v o i d   O n I n i t ( ) {  
       b o o l   S e t T i m e r = f a l s e ;  
       i f ( ! I s T e s t i n g ( ) ) {    
             f o r ( i n t   i = 0 ; i < 1 0 ; i + + ) {  
                   S e t T i m e r = E v e n t S e t T i m e r ( 6 0 ) ; / / M 1  
                   i f ( S e t T i m e r = = t r u e )  
                         b r e a k ;  
             }  
       }  
       i f ( S e t T i m e r = = f a l s e ) {  
             M e s s a g e B o x ( " C a n n o t   i n i t   t h e   e x p e r t   a d v i s o r . \ n   A t t a c h   a g a i n   t h e   e x p e r t   a d v i s o r " , " I n i t   E x p e r t   A d v i s o r " ) ;    
             r e t u r n ;  
       }  
       T i m e I n i t = T i m e C u r r e n t ( ) ;  
       / / L o a d H i s t o r y D a t a ( ) ;  
       S y m b o l s L i s t ( t r u e ) ;  
       o b j O r d e r s . I m p o r t O r d e r s ( ) ;  
       S h o w M e s s a g e s ( ) ;  
       / / P r i n t ( " U s e d L o t s ( f a l s e ) < T o t a l L o t ( ) = " , U s e d L o t s ( f a l s e ) , " < " , T o t a l L o t ( ) ) ;  
       / / P r i n t ( " U s e d L o t s ( t r u e ) < M a x L o t ( ) = " , U s e d L o t s ( t r u e ) , " < " , M a x L o t ( ) ) ;  
       / / P r i n t ( " M i n L o t = " , M a r k e t I n f o ( i S y m b o l , M O D E _ M I N L O T ) , " ,   M a x L o t = " , M a r k e t I n f o ( i S y m b o l , M O D E _ M A X L O T ) ) ;  
       / / P r i n t ( " S p r e a d = " , B i d - A s k , " ,   A v e r a g e H 4 S p r e a d = " , A v e r a g e S p r e a d N u m P e r i o d ( T F _ H 4 , 1 ) ) ;  
 }      
  
 / * d o u b l e   O n T e s t e r ( ) {  
       r e t u r n   0 ;  
 } * /  
  
 v o i d   O n T i m e r ( ) {  
       i f ( I s T e s t i n g ( ) = = f a l s e ) {  
             P r o c e s s T i c k ( ) ;  
             S h o w M e s s a g e s ( ) ;  
       }  
 }  
  
 v o i d   O n T i c k ( ) {  
        
       i f ( i V o l u m e ( S y m b o l ( ) , P e r i o d ( ) , 0 ) > 1 )   r e t u r n ;        
        
       i f ( I s T e s t i n g ( ) = = t r u e ) {  
             i f ( C u r r e n t T i m e F r a m e ( ) > T F _ M 1 ) { / / M 1 ,   M 5 .   M 1 5  
                   P r i n t ( " C h a n g e   P e r i o d   t o   M 1 " ) ;  
             }  
             P r o c e s s T i c k ( ) ;  
             / / T e s t ( ) ;  
       }  
 }  
  
 v o i d   O n C h a r t E v e n t ( c o n s t   i n t   i d , c o n s t   l o n g &   l p a r a m , c o n s t   d o u b l e &   d p a r a m , c o n s t   s t r i n g &   s p a r a m ) {  
       i f ( i d = = C H A R T E V E N T _ C H A R T _ C H A N G E )  
             S h o w M e s s a g e s ( ) ;  
 }  
  
 v o i d   O n D e i n i t ( c o n s t   i n t   r e a s o n )  
 {  
       M o d i f y T a k e P r o f i t ( ) ;  
       D e l e t e M e s s a g e s ( ) ;  
       E v e n t K i l l T i m e r ( ) ;  
       P r i n t ( " A c c o u n t B a l a n c e = " , A c c o u n t B a l a n c e ( ) , " ,   A c c o u n t P r o f i t = " , A c c o u n t P r o f i t ( ) ) ;        
        
 }  
  
  
  
  
 