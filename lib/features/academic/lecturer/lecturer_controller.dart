class LecturerController {
  // ATTRIBUTES
  String name;
  String email;
  String phoneNumber;

  // CONSTRUCTOR
  LecturerController({
    required this.name,
    required this.email,
    required this.phoneNumber,
  });

  // GETTER METHOD
  String getName() {
    return name;
  }

  String getEmail() {
    return email;
  }

  String getPhoneNumber() {
    return phoneNumber;
  }

  // SETTER METHOD
  void setName(String name) {
    this.name = name;
  }

  void setEmail(String email) {
    this.email = email;
  }

  void setPhoneNumber(String phoneNumber) {
    this.phoneNumber = phoneNumber;
  }
}

class Task {
  // ATTRIBUTES
  String title;
  int totalTask;
  String status;

  // CONSTRUCTOR
  Task({required this.title, required this.totalTask, required this.status});

  // GETTER METHOD
  String getTitle() {
    return title;
  }

  int getTotalTask() {
    return totalTask;
  }

  String getStatus() {
    return status;
  }

  // SETTER METHOD
  void setTitle(String title) {
    this.title = title;
  }

  void setTotalTask(int totalTask) {
    this.totalTask = totalTask;
  }

  void setStatus(String status) {
    this.status = status;
  }

  // METHOD
  int countTask(int task) {
    return totalTask + task;
  }
}
