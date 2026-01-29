import 'package:flutter_test/flutter_test.dart';
import 'package:manzoma/core/enums/user_role.dart';
import 'package:manzoma/core/entities/user_entity.dart';
import 'package:manzoma/features/users/domain/usecases/delete_user_usecase.dart';

void main() {
  group('UserEntity', () {
    test('should create UserEntity with required fields', () {
      final user = UserEntity(
        id: 'test-id',
        tenantId: 'tenant-1',
        email: 'test@example.com',
        role: UserRole.employee,
        name: 'Test User',
        isActive: true,
      );

      expect(user.id, 'test-id');
      expect(user.tenantId, 'tenant-1');
      expect(user.email, 'test@example.com');
      expect(user.role, UserRole.employee);
      expect(user.name, 'Test User');
      expect(user.isActive, true);
    });

    test('displayName should return name when available', () {
      final user = UserEntity(
        id: 'test-id',
        tenantId: 'tenant-1',
        email: 'test@example.com',
        role: UserRole.employee,
        name: 'Test User',
        isActive: true,
      );

      expect(user.displayName, 'Test User');
    });

    test('displayName should return email when name is null', () {
      final user = UserEntity(
        id: 'test-id',
        tenantId: 'tenant-1',
        email: 'test@example.com',
        role: UserRole.employee,
        isActive: true,
      );

      expect(user.displayName, 'test@example.com');
    });
  });

  group('UserRole', () {
    test('toValue should return correct string for each role', () {
      expect(UserRole.superAdmin.toValue(), 'super_admin');
      expect(UserRole.cad.toValue(), 'cad');
      expect(UserRole.branchManager.toValue(), 'branch_manager');
      expect(UserRole.employee.toValue(), 'employee');
    });

    test('fromValue should return correct role for each string', () {
      expect(UserRoleExtension.fromValue('super_admin'), UserRole.superAdmin);
      expect(UserRoleExtension.fromValue('cad'), UserRole.cad);
      expect(UserRoleExtension.fromValue('branch_manager'), UserRole.branchManager);
      expect(UserRoleExtension.fromValue('employee'), UserRole.employee);
    });

    test('fromValue should default to employee for unknown values', () {
      expect(UserRoleExtension.fromValue('unknown'), UserRole.employee);
    });
  });

  group('DeleteUserParams', () {
    test('should create params with id', () {
      final params = DeleteUserParams(id: 'user-123');
      expect(params.id, 'user-123');
    });
  });
}
