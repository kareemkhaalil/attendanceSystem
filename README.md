# manzoma | منظومة

![manzoma logo](https://raw.githubusercontent.com/kareemkhaalil/manzoma/refs/heads/main/assets/images/Asset%201.png)) <!-- 👈 MODIFIED: Placeholder للـ logo, استبدله برابط الصورة الفعلي -->

An All-in-One HR, Attendance, and Payroll Management System built with **Flutter** and **Supabase** for a seamless experience on Web, Mobile, and Desktop.

**manzoma** (منظومة) is a modern, responsive, and scalable Human Resources Management System designed to simplify HR operations. From employee attendance tracking to payroll automation, manzoma provides a centralized platform for businesses of all sizes, ensuring efficiency and ease of use.

The system leverages **Clean Architecture** for maintainability, **Flutter** for a consistent cross-platform UI, and **Supabase** for a robust backend, delivering a powerful and user-friendly experience.

[![Stars](https://img.shields.io/github/stars/kareemkhaalil/manzoma)](https://github.com/kareemkhaalil/manzoma/stargazers)
[![Issues](https://img.shields.io/github/issues/kareemkhaalil/manzoma)](https://github.com/kareemkhaalil/manzoma/issues)
[![License](https://img.shields.io/github/license/kareemkhaalil/manzoma)](https://github.com/kareemkhaalil/manzoma/blob/main/LICENSE)
![Flutter Version](https://img.shields.io/badge/Flutter-3.22-blue)
![Supabase](https://img.shields.io/badge/Supabase-0.8-green)

---

## ✨ Core Features

| Feature                  | Status         | Description                                                                 |
|--------------------------|----------------|-----------------------------------------------------------------------------|
| 🔐 **Authentication**     | ✅ Complete    | Secure user login, registration, and session management using Supabase Auth. |
| 👤 **User Management**    | ✅ Complete    | Create, update, and manage user profiles with role-based access control (Super Admin, Admin, Employee). Enhanced with read-only client fields and preserved original data on edit. |
| 🏢 **Client & Branch Mgmt** | ✅ Complete    | Manage multiple clients and branches, with seamless assignment of users and resources. |
| ⏰ **Attendance Tracking**| ✅ Complete    | Real-time employee check-in/check-out with detailed daily and monthly logs.  |
| 💸 **Payroll Management** | 🚧 In-Progress | Automate salary calculations, deductions, and payslip generation based on attendance and contracts. |
| 📊 **Reporting & Analytics** | 🚧 In-Progress | Generate detailed reports for attendance, payroll, and user activity, exportable to PDF & CSV. |
| 📱 **Responsive UI**      | ✅ Complete    | Adaptive, beautiful UI for Web, iOS, Android, and Desktop from a single codebase. |
| 🔔 **Notifications**      | 📅 Planned     | Real-time alerts for events like leave approvals and attendance reminders.   |

---

## 📷 Screenshots

<!-- 👈 MODIFIED: أضف screenshots هنا -->
| User Management | Attendance Tracking | Payroll Dashboard |
|-----------------|---------------------|-------------------|
| ![User Management](https://via.placeholder.com/300x600?text=User+Management) | ![Attendance](https://via.placeholder.com/300x600?text=Attendance) | ![Payroll](https://via.placeholder.com/300x600?text=Payroll) |

*Note*: Replace placeholder images with actual screenshots from the app.

---

## 🛠️ Tech Stack & Architecture

- **Frontend**: Flutter (cross-platform development for Web, iOS, Android, Desktop)
- **Backend**: Supabase (Postgres Database, Authentication, Storage, Edge Functions)
- **Architecture**: Clean Architecture (Domain, Data, Presentation layers)
- **State Management**: BLoC / Cubit (predictable state management)
- **Navigation**: GoRouter (declarative, URL-based routing)
- **Dependency Injection**: GetIt (service locator for inversion of control)
- **Testing**: Mockito & bloc_test (unit and widget testing)

---

## 🚀 Getting Started

Follow these steps to set up and run **manzoma** locally.

### Prerequisites
- Flutter SDK (v3.22 or higher)
- Dart SDK
- Supabase account
- Git

### Installation
1. **Clone the repository**:
   ```bash
   git clone https://github.com/kareemkhaalil/manzoma.git
   cd manzoma
   ```

2. **Install dependencies**:
   ```bash
   flutter pub get
   ```

3. **Configure Supabase**:
   - Create a new project on [supabase.com](https://supabase.com).
   - Navigate to `Project Settings` > `API` to find your `Project URL` and `anon (public) key`.
   - Create a `.env` file in the project root:
     ```env
     SUPABASE_URL=YOUR_SUPABASE_URL
     SUPABASE_ANON_KEY=YOUR_SUPABASE_ANON_KEY
     ```
   - Run the SQL scripts in `supabase/migrations` in the Supabase SQL Editor to set up database tables and roles.

4. **Run the application**:
   ```bash
   flutter run
   ```

---

## 🧪 Running Tests

Ensure code stability by running the test suite:
```bash
flutter test
```

---

## 📋 Changelog

### Recent Updates
- **User Management Enhancements** (Sep 2025):
  - Fixed `TypeError` in `UsersEditScreen` by properly converting `ClientModel` to `ClientEntity`.
  - Replaced client dropdown with a read-only `TextFormField` to display the client's name, matching the dropdown's styling.
  - Ensured original user data (name, email, phone, etc.) is preserved if no changes are made during editing.
- **UI Improvements**:
  - Enhanced responsiveness in `UsersScreen` and `UsersEditScreen` with `flutter_screenutil` for adaptive layouts.
  - Improved error handling for client loading failures in `UsersEditScreen`.
- **Bug Fixes**:
  - Resolved tenant ID mismatch issues for non-superAdmin users.

*See [Commits](https://github.com/kareemkhaalil/manzoma/commits/main) for detailed changes.*

---

## 🤝 How to Contribute

We welcome contributions to make **manzoma** even better! Here’s how you can help:
1. **Fork the repository**.
2. Create a new branch:
   ```bash
   git checkout -b feature/YourAmazingFeature
   ```
3. Make your changes and commit:
   ```bash
   git commit -m 'Add some AmazingFeature'
   ```
4. Push to your branch:
   ```bash
   git push origin feature/YourAmazingFeature
   ```
5. Open a Pull Request with a clear description of your changes.

### Contribution Ideas
- Fix bugs in payroll calculations or attendance tracking.
- Add support for notifications using Supabase Edge Functions.
- Improve test coverage for `UserCubit` and `ClientCubit`.
- Enhance UI with animations or additional themes.

Check the [Issues](https://github.com/kareemkhaalil/manzoma/issues) page for open tasks.

---

## 📄 License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

---

<div align="center">
  <p>Made with ❤️ by <strong>Kareem Khalil</strong></p>
  <p>Follow me on <a href="https://github.com/kareemkhaalil">GitHub</a> | <a href="https://linkedin.com/in/kareemkhalil">LinkedIn</a></p>
</div>
