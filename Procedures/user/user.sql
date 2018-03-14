CREATE OR REPLACE FUNCTION existsEmailUser(
  pEmail VARCHAR
)
  RETURNS JSON AS $$
BEGIN
  IF EXISTS(SELECT id
            FROM public.user
            WHERE email ILIKE pEmail)
  THEN
    RETURN
    json_build_object(
        'executionCode', 1,
        'message', 'Email já possui cadastro'
    );
  ELSE
    RETURN
    json_build_object(
        'message', 'Email disponivel'
    );
  END IF;
END;
$$
LANGUAGE plpgsql;
-- EXEMPLO
SELECT *
FROM existsEmailUser('gabrielferrer@outlook.com.br');

CREATE OR REPLACE FUNCTION insertUser(
  pName  VARCHAR,
  pEmail VARCHAR,
  pPass  VARCHAR,
  pImage VARCHAR
)
  RETURNS JSON AS $$
BEGIN
  IF EXISTS(SELECT id
            FROM public.user
            WHERE email ILIKE pEmail)
  THEN
    RETURN
    json_build_object(
        'executionCode', 1,
        'message', 'Email já possui cadastro'
    );
  END IF;

  INSERT INTO public.user (name, email, pass, image) VALUES (pName, pEmail, pPass, pImage);

  RETURN
  json_build_object(
      'executionCode', 0,
      'message', 'OK'
  );
END;
$$
LANGUAGE plpgsql;
-- EXEMPLO
SELECT *
FROM insertUser('Gabriel', 'Gabrielferrer2@outlook.com.br', '9141', '');

CREATE OR REPLACE FUNCTION changeUser(
  pId      INTEGER,
  pName    VARCHAR,
  pEmail   VARCHAR,
  pPass    VARCHAR,
  pRemoved BOOLEAN,
  pImage   VARCHAR
)
  RETURNS JSON AS $$
BEGIN
  IF NOT EXISTS(SELECT id
                FROM public.user
                WHERE id = pId)
  THEN
    RETURN
    json_build_object(
        'executionCode', 1,
        'message', 'Usuario não encontrado'
    );
  END IF;

  IF EXISTS(SELECT email
            FROM public.user
            WHERE email ILIKE pEmail AND id <> pId)
  THEN
    RETURN
    json_build_object(
        'executionCode', 2,
        'message', 'E-mail já possui cadastro'
    );
  END IF;


  IF pImage IS NOT NULL
  THEN
    UPDATE public.user
    SET
      name  = pName,
      email = pEmail,
      pass  = pPass,
      image = pImage
    WHERE id = pId;

  ELSEIF pImage IS NULL AND pRemoved
    THEN
      UPDATE public.user
      SET
        name  = pName,
        email = pEmail,
        pass  = pPass,
        image = NULL
      WHERE id = pId;
  ELSE
    UPDATE public.user
    SET
      name  = pName,
      email = pEmail,
      pass  = pPass
    WHERE id = pId;
  END IF;

  RETURN
  json_build_object(
      'message', 'OK'
  );
END;
$$
LANGUAGE plpgsql;

-- EXEMPLO
SELECT * FROM changeUser(21, 'Gabriel', 'gabrielferrer2@outlook.com.br', 'PoliciaFederal2018', true, NULL);
SELECT * FROM public.user;

CREATE OR REPLACE FUNCTION verifyChangeEmail(
  pId    INTEGER,
  pEmail VARCHAR
)
  RETURNS JSON AS $$
DECLARE
  vImage VARCHAR;
BEGIN
  IF EXISTS(SELECT id
            FROM public.user
            WHERE email ILIKE pEmail AND pId <> id)
  THEN
    RETURN
    json_build_object(
        'executionCode', 1,
        'message', 'Email já possui cadastro'
    );
  ELSE
    SELECT image
    INTO vImage
    FROM public.user
    WHERE pId = id;
    RETURN
    json_build_object(
        'path', vImage
    );
  END IF;
END;
$$
LANGUAGE plpgsql;

SELECT *
FROM verifyChangeEmail(21, 'gabrielferrer2@outlook.com.br');

-- DECLARE
--   vCaminhoAntigo varchar;
-- BEGIN
--
-- SELECT img INTO vCaminhoAntigo FROM user WHERE id = pId;

-- IF pImg IS NOT NULL THEN
--   update user set img = pImg where id = pId;
-- END IF;
--
-- update user set nome = pNome, email =  pEmail;
--
-- return json_build_object(
-- 'caminho antigo', vCaminhoAntigo
-- )
-- END