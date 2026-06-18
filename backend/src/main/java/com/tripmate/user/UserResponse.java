package com.tripmate.user;

import java.time.OffsetDateTime;

// 엔티티를 직접 노출하지 않고 필요한 필드만 반환 (password_hash 노출 방지)
public record UserResponse(Long id, String email, String nickname, OffsetDateTime createdAt) {
    public static UserResponse from(User user) {
        return new UserResponse(user.getId(), user.getEmail(), user.getNickname(), user.getCreatedAt());
    }
}
