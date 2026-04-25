# Work Now, Play Now
Work Now, Play Now is a JavaScript-based task tracker designed to increase productivity through motivation and rewards. Built with real-world situations in mind, it helps users stay focused by pairing task completion with rewards. 
## Features
- **Add a Task**: Create new tasks with just a few clicks
- **Delete a Task**: Easily delete a task that you no longer need
- **Streak Builder**: Log in every day to increase streak and unlock achievements
- **Reward System**: Finish tasks to receive rewards to encourage productivity 
- **Calendar Sync**: Easily sync the app to your Google Calendar to have tasks and events all in one place
## Getting Started
> Work Now, Play Now is a web application that can run on any web browser. 
### From Release
**Live at [worknowplaynow.com](https://worknowplaynow.com)**
## Building From Source Code
### Prerequisites
Make sure you have the following installed:
- [Node.js](https://nodejs.org/) (v18 or higher)
- [npm](https://www.npmjs.com/)
- A [Supabase](https://supabase.com) account and project
---
1. **Clone the repository:**
   
```bash
git clone https://github.com/YOUR_USERNAME/worknowplaynow.git
cd worknowplaynow
```
---  
2. **Install Dependencies:**
```bash
npm install
```
---
3. **Set up Environmental Variable:**
```
SUPABASE_URL=your_supabase_project_url_here
SUPABASE_ANON_KEY=your_supabase_anon_key_here
```
---
4. **Set up the Database:**
   
In your Supabase project, run the SQL from `database/schema.sql` in the Supabase SQL editor to create all schema.
---
5. **Run the App:**
    
Use either 
```bash
node index.js
```
 or
```bash
node .
```
---
6. **(Optional) Google OAuth and Calendar Set up:**
   
To use the Google Sign-In and Calendar integration locally you need to
   - Go to [Google Cloud Console](https://console.cloud.google.com)
   - Add "https://localhost:8080" to **Authorized JavaScript Origins** on your OAuth credentials
	- Add "https://localhost:8080" as a test user if the app is still in testing mode.
---
## Tech Stack
| Layer | Technology |
|---|---|
| Frontend | HTML, CSS, Vanilla JS |
| Backend | Node.js, Express |
| Database | Supabase (PostgreSQL) |
| Auth | Supabase Auth + Google OAuth |
| Hosting | Railway |
| Domain | [worknowplaynow.com](https://worknowplaynow.com) |
---
## Project Structure
```
├── index.js              # Express server entry point
├── database/
│   └── schema.sql        # Full database schema, RLS policies & seed data
├── routes/               # API route handlers
│   ├── auth.js
│   ├── tasks.js
│   ├── goals.js
│   ├── points.js
│   ├── streaks.js
│   ├── categories.js
│   └── achievements.js
├── lib/                  # Shared business logic
│   ├── supabase.js
│   ├── points.js
│   ├── streaks.js
│   └── achievements.js
├── models/               # Data models
│   ├── task.js
│   └── goal.js
├── middlewares/
│   └── auth.js           # JWT verification middleware
└── public/               # Static frontend files
    ├── index.html        # Landing page
    ├── app.html          # Dashboard
    ├── privacy.html
    ├── terms.html
    ├── contact.html
    ├── styles/
    │   └── index.css
    ├── js/
    │   ├── auth.js
    │   └── app.js
    ├── image/
    └── fonts/
```
---
## Team
Built by students at University of North Georgia as part of CSCI3300 Software Development.

Ian Holbrook, Joshua Garcia, Katie Grace Hickman, & Ezra Holloway
