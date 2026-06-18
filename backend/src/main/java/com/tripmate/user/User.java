package com.tripmate.user;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.time.OffsetDateTime;

@Entity
@Table(name = "users")
@Getter
@NoArgsConstructor
public class User {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, unique = true)
    private String email;

    // 실제 비밀번호가 아니라 BCrypt 해시값을 저장 — 원문 복원 불가
    @Column(name = "password_hash", nullable = false)
    private String passwordHash;

    @Column(nullable = false, length = 50)
    private String nickname;

    // DB default(now())가 채우는 컬럼 — JPA가 INSERT/UPDATE 시 건드리지 않음
    @Column(name = "created_at", insertable = false, updatable = false)
    private OffsetDateTime createdAt;

    public User(String email, String passwordHash, String nickname) {
        this.email = email;
        this.passwordHash = passwordHash;
        this.nickname = nickname;
    }
}
