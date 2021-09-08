# Password Wallet

### A mobile application for managing passwords

The goal of this project is to create a mobile application for Android that allows users to store and manage their passwords in encrypted form.

The application supports HMAC and SHA-512 encryption algorithms. 
The application uses algorithm implementations provided by the [Pointy Castle package](https://pub.dev/packages/pointycastle), which is based on implementations from [the Bouncy Castle](https://bouncycastle.org/).

[BloC library](https://bloclibrary.dev/), by Felix Angelov, is used to manage application state.

Application code coverage is measured by LCOV and is 90.4%.

## Getting Started

These instructions will get you a copy of the project up and running on 
your local machine for development and testing purposes.

### Prerequisites

* Flutter SDK - https://flutter.dev/
* The Android emulator (requires setup in Android Studio) - https://developer.android.com/studio/

Detailed information about installation and configurations are provided at developers' site.

## Technology Stack

* Flutter
* SQLite

## Preview

<table>
    <tr>
        <td>
            <p>User Registration</p>
            <img src="images/img_1.png" alt="user registration" title="User Registration">
        </td>
        <td>
            <p>Passwords Management</p>
            <img src="images/img_2.png" alt="passwords management" title="Passwords Management">
        </td>
        <td>
            <p>Adding Password</p>
            <img src="images/img_3.png" alt="adding password" title="Adding Password">
        </td>
    </tr>
    <tr>
        <td>
            <p>Changing User Password</p>
            <img src="images/img_4.png" alt="changing user password" title="Changing User Password">
        </td>
        <td>
            <p>Login Logs</p>
            <img src="images/img_5.png" alt="login logs" title="Login Logs">
        </td>
        <td>
            <p>Activity Logs</p>
            <img src="images/img_6.png" alt="activity logs" title="Activity Logs">
        </td>
    </tr>
    <tr>
        <td>
            <p>Data Changes</p>
            <img src="images/img_7.png" alt="data changes" title="Data Changes">
        </td>
    </tr>
</table>

## Author

* **Michał Koziara** 
