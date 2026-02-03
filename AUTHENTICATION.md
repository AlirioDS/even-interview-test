# 🔐 **Authentication & Authorization Guide**

Your Rails 8 API now includes a **complete authentication and authorization system** with JWT tokens and role-based access control.

## 🎯 **System Overview**

### **Authentication (Who you are)**
- **JWT-based** - Stateless token authentication
- **Refresh tokens** - Secure token renewal
- **Role-based** - User, Editor, Admin roles

### **Authorization (What you can do)**
- **Pundit policies** - Clean, testable authorization
- **Role-based permissions** - Fine-grained access control
- **Resource scoping** - Users see only what they should

---

## 🚀 **Quick Start**

### **1. Install Dependencies**
```bash
bundle install
```

### **2. Run Migrations & Seeds**
```bash
docker compose exec rails-api bin/rails db:migrate
docker compose exec rails-api bin/rails db:seed
```

### **3. Test the API**
```bash
# Register a new user
curl -X POST http://localhost:3000/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email_address": "test@example.com",
    "password": "password123",
    "password_confirmation": "password123",
    "first_name": "Test",
    "last_name": "User"
  }'

# Login
curl -X POST http://localhost:3000/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email_address": "admin@example.com",
    "password": "password123"
  }'
```

---

## 📋 **API Endpoints**

### **🔑 Authentication Endpoints**

| Method | Endpoint | Description | Auth Required |
|--------|----------|-------------|---------------|
| `POST` | `/api/v1/auth/register` | Register new user | ❌ |
| `POST` | `/api/v1/auth/login` | Login user | ❌ |
| `POST` | `/api/v1/auth/refresh` | Refresh JWT token | ❌ |
| `DELETE` | `/api/v1/auth/logout` | Logout user | ✅ |
| `GET` | `/api/v1/auth/me` | Get current user | ✅ |

### **👥 User Management Endpoints**

| Method | Endpoint | Description | Required Role |
|--------|----------|-------------|---------------|
| `GET` | `/api/v1/users` | List users | Admin |
| `GET` | `/api/v1/users/:id` | Get user | Admin or Self |
| `POST` | `/api/v1/users` | Create user | Admin |
| `PATCH` | `/api/v1/users/:id` | Update user | Admin or Self |
| `DELETE` | `/api/v1/users/:id` | Delete user | Admin |
| `PATCH` | `/api/v1/users/:id/change_role` | Change user role | Admin |

---

## 🔒 **Authentication Flow**

### **1. Registration**
```bash
curl -X POST http://localhost:3000/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email_address": "user@example.com",
    "password": "password123",
    "password_confirmation": "password123",
    "first_name": "John",
    "last_name": "Doe"
  }'
```

**Response:**
```json
{
  "message": "Registration successful",
  "user": {
    "id": 1,
    "email_address": "user@example.com",
    "first_name": "John",
    "last_name": "Doe",
    "role": "user"
  },
  "token": "eyJhbGciOiJIUzI1NiJ9...",
  "refresh_token": "eyJhbGciOiJIUzI1NiJ9..."
}
```

### **2. Login**
```bash
curl -X POST http://localhost:3000/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email_address": "user@example.com",
    "password": "password123"
  }'
```

### **3. Using JWT Token**
```bash
curl -X GET http://localhost:3000/api/v1/auth/me \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiJ9..."
```

### **4. Refresh Token**
```bash
curl -X POST http://localhost:3000/api/v1/auth/refresh \
  -H "Content-Type: application/json" \
  -d '{
    "refresh_token": "eyJhbGciOiJIUzI1NiJ9..."
  }'
```

---

## 👤 **User Roles**

### **Role Hierarchy**
1. **👑 Admin** - Full system access
2. **✏️ Editor** - Content management
3. **👤 User** - Basic access

### **Default Permissions**

| Action | User | Editor | Admin |
|--------|------|--------|-------|
| **Create users** | ❌ | ❌ | ✅ |
| **View all users** | ❌ | ❌ | ✅ |
| **Edit own profile** | ✅ | ✅ | ✅ |
| **Edit other users** | ❌ | ❌ | ✅ |
| **Delete users** | ❌ | ❌ | ✅ |
| **Change roles** | ❌ | ❌ | ✅ |

---

## 🛡️ **Authorization with Pundit**

### **How Policies Work**
```ruby
# app/policies/user_policy.rb
class UserPolicy < ApplicationPolicy
  def show?
    user.present? && (user.admin? || user == record)
  end
  
  def update?
    user.present? && (user.admin? || user == record)
  end
  
  def destroy?
    user&.admin? && user != record
  end
end
```

### **Using Policies in Controllers**
```ruby
class Api::V1::UsersController < ApplicationController
  def show
    @user = User.find(params[:id])
    authorize @user  # Uses UserPolicy#show?
    
    render json: { user: user_data(@user) }
  end
end
```

### **Creating Custom Policies**
```bash
# Generate a new policy
touch app/policies/post_policy.rb
```

```ruby
class PostPolicy < ApplicationPolicy
  def create?
    user.present? && (user.admin? || user.editor?)
  end
  
  def update?
    user.present? && (user.admin? || user == record.author)
  end
  
  def destroy?
    user.present? && (user.admin? || user == record.author)
  end
  
  class Scope < ApplicationPolicy::Scope
    def resolve
      if user&.admin?
        scope.all
      elsif user&.editor?
        scope.published.or(scope.where(author: user))
      else
        scope.published
      end
    end
  end
end
```

---

## 🧪 **Testing Authentication**

### **Test Users (from seeds)**
```
📧 admin@example.com (password: password123) - Admin role
📧 editor@example.com (password: password123) - Editor role  
📧 user@example.com (password: password123) - User role
```

### **Testing Different Roles**

**1. Login as Admin:**
```bash
curl -X POST http://localhost:3000/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email_address": "admin@example.com", "password": "password123"}'
```

**2. Try Admin-only Action:**
```bash
curl -X GET http://localhost:3000/api/v1/users \
  -H "Authorization: Bearer YOUR_ADMIN_TOKEN"
```

**3. Login as Regular User:**
```bash
curl -X POST http://localhost:3000/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email_address": "user@example.com", "password": "password123"}'
```

**4. Try Admin Action (Should Fail):**
```bash
curl -X GET http://localhost:3000/api/v1/users \
  -H "Authorization: Bearer YOUR_USER_TOKEN"
# Response: {"error": "You are not authorized to perform this action"}
```

---

## ⚙️ **Configuration**

### **JWT Settings**
JWT tokens are configured in `User` model:
- **Access token expiry**: 24 hours
- **Refresh token expiry**: 7 days
- **Secret key**: `Rails.application.secret_key_base`

### **Customizing Token Expiry**
```ruby
# In User model
def generate_jwt_token
  payload = {
    user_id: id,
    email: email_address,
    role: role,
    exp: 1.hour.from_now.to_i  # Custom expiry
  }
  JWT.encode(payload, jwt_secret_key, 'HS256')
end
```

### **Adding New Roles**
```ruby
# In User model
enum role: { 
  user: 'user', 
  editor: 'editor', 
  admin: 'admin',
  moderator: 'moderator'  # Add new role
}
```

---

## 🔧 **Extending the System**

### **1. Add OAuth Providers**
```ruby
# Gemfile
gem 'omniauth'
gem 'omniauth-google-oauth2'
gem 'omniauth-rails_csrf_protection'
```

### **2. Add API Rate Limiting**
```ruby
# Gemfile  
gem 'rack-attack'

# config/application.rb
config.middleware.use Rack::Attack
```

### **3. Add Token Blacklisting**
```ruby
# Create blacklisted_tokens table
class CreateBlacklistedTokens < ActiveRecord::Migration[8.0]
  def change
    create_table :blacklisted_tokens do |t|
      t.string :jti, null: false
      t.datetime :expires_at, null: false
      t.timestamps
    end
    
    add_index :blacklisted_tokens, :jti, unique: true
    add_index :blacklisted_tokens, :expires_at
  end
end
```

---

## 🚨 **Security Best Practices**

### **✅ Implemented**
- ✅ Password hashing with `bcrypt`
- ✅ JWT token expiration
- ✅ Role-based authorization
- ✅ Input validation
- ✅ Secure headers in API responses

### **🔒 Production Recommendations**
1. **Use HTTPS only** in production
2. **Store JWT secret** in environment variables
3. **Implement token blacklisting** for logout
4. **Add rate limiting** to auth endpoints
5. **Monitor authentication failures**
6. **Use strong passwords** enforcement
7. **Add email verification** for registration
8. **Implement account lockout** after failed attempts

---

## 🐛 **Common Issues & Solutions**

### **❌ "Authentication token required"**
**Problem**: Missing or invalid Authorization header
**Solution**: Include `Authorization: Bearer TOKEN` header

### **❌ "Invalid or expired token"**  
**Problem**: JWT token has expired or is malformed
**Solution**: Use refresh token to get new access token

### **❌ "You are not authorized to perform this action"**
**Problem**: User role doesn't have permission  
**Solution**: Check role requirements in policy classes

### **❌ "User not found"**
**Problem**: Token valid but user deleted
**Solution**: Handle deleted users in authentication

---

## 📚 **Next Steps**

### **Immediate**
1. **Test all endpoints** with different roles
2. **Customize policies** for your domain models
3. **Add email verification** (optional)

### **Production Ready**
1. **Set up proper secrets** management
2. **Add monitoring** and logging
3. **Implement rate limiting**
4. **Add comprehensive tests**

### **Advanced Features**
1. **Multi-tenant** architecture
2. **OAuth provider** integration
3. **Advanced RBAC** with permissions
4. **Audit logging** for security events

---

**🎉 Your Rails API now has enterprise-grade authentication and authorization!**

For questions or issues, check the `User`, `ApplicationController`, and policy files for implementation details. 
