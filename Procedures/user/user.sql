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

CREATE OR REPLACE FUNCTION changeUser(
    pId       INTEGER,
    pName     VARCHAR,
    pEmail    VARCHAR,
    pPass     VARCHAR,
    pImage    VARCHAR
)
  RETURNS JSON AS $$

  BEGIN
    IF NOT EXISTS(SELECT id FROM public.user WHERE id = pId)
      THEN
      RETURN
        json_build_object(
          'executionCode', 1,
          'message', 'Usuario não encontrado'
        );
    END IF;

    IF EXISTS(SELECT email FROM public.user WHERE email ILIKE pEmail AND id <> pId)
      THEN
      RETURN
        json_build_object(
          'executionCode', 2,
          'message', 'E-mail já possui cadastro'
        );
    END IF;

    UPDATE public.user
    SET
      name    = pName,
      email   = pEmail,
      pass    = pPass,
      image   = pImage
    WHERE id = pId;

    RETURN
    json_build_object(
      'executionCode', 0,
      'message', 'OK'
    );
  END;
$$
  LANGUAGE plpgsql;


SELECT * FROM insertUser('Gabriel', 'Gabrielferrer2@outlook.com.br', '9141', '');

SELECT * FROM public.user;

SELECT * FROM changeUser(1, 'TesteA', 'teste@t2.com', '123', '');