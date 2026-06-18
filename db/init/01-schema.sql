-- =====================================================================
-- tripmate 초기 스키마
-- 컨테이너 최초 기동 시 자동 실행됩니다 (docker-entrypoint-initdb.d).
-- 5개 테이블: users / plans / plan_items / mate_requests / mate_applications
-- =====================================================================

-- 사용자 -------------------------------------------------------------
CREATE TABLE users (
    id            BIGSERIAL    PRIMARY KEY,
    email         VARCHAR(255) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,            -- BCrypt 해시 저장 (평문 금지)
    nickname      VARCHAR(50)  NOT NULL,
    created_at    TIMESTAMPTZ  NOT NULL DEFAULT now()
);

-- 여행 계획 -----------------------------------------------------------
CREATE TABLE plans (
    id          BIGSERIAL    PRIMARY KEY,
    user_id     BIGINT       NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    title       VARCHAR(200) NOT NULL,
    destination VARCHAR(200) NOT NULL,
    start_date  DATE,
    end_date    DATE,
    budget      INTEGER,                            -- 단위: 원
    preferences TEXT,                               -- 사용자가 입력한 취향 원문 (AI 입력값)
    is_public   BOOLEAN      NOT NULL DEFAULT false,
    created_at  TIMESTAMPTZ  NOT NULL DEFAULT now(),
    updated_at  TIMESTAMPTZ  NOT NULL DEFAULT now()
);

-- 일정 항목 (AI가 생성한 일자별 일정) ---------------------------------
CREATE TABLE plan_items (
    id          BIGSERIAL    PRIMARY KEY,
    plan_id     BIGINT       NOT NULL REFERENCES plans(id) ON DELETE CASCADE,
    day_number  INTEGER      NOT NULL,              -- 며칠째 (1, 2, 3 ...)
    sort_order  INTEGER      NOT NULL,              -- 그날 안에서의 순서
    start_time  TIME,
    title       VARCHAR(200) NOT NULL,
    description TEXT,
    location    VARCHAR(255),
    created_at  TIMESTAMPTZ  NOT NULL DEFAULT now()
);

-- 동행 모집 글 (plan에 대한 모집) -------------------------------------
CREATE TABLE mate_requests (
    id         BIGSERIAL    PRIMARY KEY,
    plan_id    BIGINT       NOT NULL REFERENCES plans(id) ON DELETE CASCADE,
    capacity   INTEGER      NOT NULL DEFAULT 1,     -- 모집 인원
    conditions TEXT,                                -- 동행 조건 (성별/연령대/스타일 등)
    status     VARCHAR(20)  NOT NULL DEFAULT 'OPEN',-- OPEN / CLOSED
    created_at TIMESTAMPTZ  NOT NULL DEFAULT now()
);

-- 동행 신청 -----------------------------------------------------------
CREATE TABLE mate_applications (
    id              BIGSERIAL   PRIMARY KEY,
    mate_request_id BIGINT      NOT NULL REFERENCES mate_requests(id) ON DELETE CASCADE,
    applicant_id    BIGINT      NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    message         TEXT,
    status          VARCHAR(20) NOT NULL DEFAULT 'PENDING', -- PENDING / ACCEPTED / REJECTED
    created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
    -- 같은 모집글에 같은 사람이 중복 신청하지 못하도록
    UNIQUE (mate_request_id, applicant_id)
);

-- 인덱스 (피드/목록 조회 성능 — 공고 "대용량 query·index" 어필 포인트) --
CREATE INDEX idx_plans_public_created ON plans (is_public, created_at DESC);
CREATE INDEX idx_plans_user           ON plans (user_id);
CREATE INDEX idx_plan_items_plan      ON plan_items (plan_id, day_number, sort_order);
CREATE INDEX idx_mate_requests_status ON mate_requests (status, created_at DESC);
CREATE INDEX idx_mate_apps_request    ON mate_applications (mate_request_id);
CREATE INDEX idx_mate_apps_applicant  ON mate_applications (applicant_id);
