class QuizGrader {
    constructor() {
        this.quizData = null;
        this.userAnswers = {};
        this.currentMode = null;
        this.shuffledQuestions = [];
        this.init();
    }

    init() {
        this.bindEvents();
    }

    formatReference(ref) {
        // Check if the reference is a URL
        const urlPattern = /^https?:\/\/.+/i;
        if (urlPattern.test(ref)) {
            return `<a href="${ref}" target="_blank" rel="noopener noreferrer" class="text-blue-600 hover:text-blue-800 underline">${ref}</a>`;
        }
        return ref;
    }

    bindEvents() {
        document.getElementById('quiz-file').addEventListener('change', this.handleFileUpload.bind(this));
        document.getElementById('practice-mode').addEventListener('click', () => this.startQuiz('practice'));
        document.getElementById('exam-mode').addEventListener('click', () => this.startQuiz('exam'));
        document.getElementById('grade-quiz').addEventListener('click', this.gradeQuiz.bind(this));
        document.getElementById('review-all').addEventListener('click', () => this.showReview('all'));
        document.getElementById('review-incorrect').addEventListener('click', () => this.showReview('incorrect'));
        document.getElementById('restart-quiz').addEventListener('click', this.restartQuiz.bind(this));
    }

    handleFileUpload(event) {
        const file = event.target.files[0];
        if (!file) return;

        const reader = new FileReader();
        reader.onload = (e) => {
            try {
                this.quizData = JSON.parse(e.target.result);
                this.validateQuizData();
                this.showModeSelection();
            } catch (error) {
                this.showDetailedError(error, e.target.result, file.name);
            }
        };
        reader.readAsText(file);
    }

    validateQuizData() {
        // Check top-level structure
        if (!this.quizData || typeof this.quizData !== 'object') {
            throw new Error('VALIDATION_ERROR: Root object is missing or invalid. Expected an object with quiz data.');
        }

        // Check required top-level fields
        const requiredTopFields = ['title', 'questions'];
        for (const field of requiredTopFields) {
            if (!this.quizData.hasOwnProperty(field)) {
                throw new Error(`VALIDATION_ERROR: Missing required field "${field}" in quiz data root object.`);
            }
        }

        if (typeof this.quizData.title !== 'string' || this.quizData.title.trim() === '') {
            throw new Error('VALIDATION_ERROR: Field "title" must be a non-empty string.');
        }

        if (!Array.isArray(this.quizData.questions)) {
            throw new Error('VALIDATION_ERROR: Field "questions" must be an array.');
        }

        if (this.quizData.questions.length === 0) {
            throw new Error('VALIDATION_ERROR: Questions array is empty. At least one question is required.');
        }

        // Check each question
        const requiredQuestionFields = ['question', 'correct_answer', 'wrong_answers'];
        const optionalQuestionFields = ['explanation', 'references', 'category'];
        
        for (let i = 0; i < this.quizData.questions.length; i++) {
            const q = this.quizData.questions[i];
            const questionNumber = i + 1;

            // Check if question is an object
            if (!q || typeof q !== 'object') {
                throw new Error(`VALIDATION_ERROR: Question ${questionNumber} is not a valid object.`);
            }

            // Check required fields
            for (const field of requiredQuestionFields) {
                if (!q.hasOwnProperty(field)) {
                    throw new Error(`VALIDATION_ERROR: Question ${questionNumber} is missing required field "${field}".`);
                }
            }

            // Validate question field
            if (typeof q.question !== 'string' || q.question.trim() === '') {
                throw new Error(`VALIDATION_ERROR: Question ${questionNumber} field "question" must be a non-empty string.`);
            }

            // Validate correct_answer field
            if (typeof q.correct_answer !== 'string' || q.correct_answer.trim() === '') {
                throw new Error(`VALIDATION_ERROR: Question ${questionNumber} field "correct_answer" must be a non-empty string.`);
            }

            // Validate wrong_answers field
            if (!Array.isArray(q.wrong_answers)) {
                throw new Error(`VALIDATION_ERROR: Question ${questionNumber} field "wrong_answers" must be an array.`);
            }

            if (q.wrong_answers.length === 0) {
                throw new Error(`VALIDATION_ERROR: Question ${questionNumber} field "wrong_answers" cannot be empty. At least one wrong answer is required.`);
            }

            // Validate each wrong answer
            for (let j = 0; j < q.wrong_answers.length; j++) {
                if (typeof q.wrong_answers[j] !== 'string' || q.wrong_answers[j].trim() === '') {
                    throw new Error(`VALIDATION_ERROR: Question ${questionNumber} wrong_answers[${j}] must be a non-empty string.`);
                }
            }

            // Check for duplicate answers
            const allAnswers = [q.correct_answer, ...q.wrong_answers];
            const uniqueAnswers = [...new Set(allAnswers)];
            if (allAnswers.length !== uniqueAnswers.length) {
                throw new Error(`VALIDATION_ERROR: Question ${questionNumber} has duplicate answers. All answers must be unique.`);
            }

            // Validate optional fields if present
            if (q.hasOwnProperty('explanation') && (typeof q.explanation !== 'string' || q.explanation.trim() === '')) {
                throw new Error(`VALIDATION_ERROR: Question ${questionNumber} field "explanation" must be a non-empty string if provided.`);
            }

            if (q.hasOwnProperty('category') && (typeof q.category !== 'string' || q.category.trim() === '')) {
                throw new Error(`VALIDATION_ERROR: Question ${questionNumber} field "category" must be a non-empty string if provided.`);
            }

            if (q.hasOwnProperty('references')) {
                if (!Array.isArray(q.references)) {
                    throw new Error(`VALIDATION_ERROR: Question ${questionNumber} field "references" must be an array if provided.`);
                }
                for (let k = 0; k < q.references.length; k++) {
                    if (typeof q.references[k] !== 'string' || q.references[k].trim() === '') {
                        throw new Error(`VALIDATION_ERROR: Question ${questionNumber} references[${k}] must be a non-empty string.`);
                    }
                }
            }
        }
    }

    showDetailedError(error, jsonContent, filename) {
        let errorDetails = '';
        let errorTitle = 'Quiz File Error';
        
        if (error.message.startsWith('VALIDATION_ERROR:')) {
            // This is our custom validation error
            errorTitle = 'Quiz Validation Error';
            errorDetails = `<div class="bg-red-50 border border-red-200 rounded-lg p-4">
                <h3 class="font-bold text-red-800 mb-2">❌ ${errorTitle}</h3>
                <p class="text-red-700 mb-3">${error.message.replace('VALIDATION_ERROR: ', '')}</p>
                <div class="text-sm text-red-600">
                    <p><strong>File:</strong> ${filename}</p>
                    <p><strong>What to do:</strong> Check your JSON file structure and ensure all required fields are present and properly formatted.</p>
                </div>
            </div>`;
        } else if (error instanceof SyntaxError) {
            // This is a JSON parsing error
            errorTitle = 'JSON Parsing Error';
            const lineInfo = this.getLineAndColumnFromError(error, jsonContent);
            
            errorDetails = `<div class="bg-red-50 border border-red-200 rounded-lg p-4">
                <h3 class="font-bold text-red-800 mb-2">❌ ${errorTitle}</h3>
                <p class="text-red-700 mb-3">The JSON file contains invalid syntax and cannot be parsed.</p>
                <div class="bg-red-100 border border-red-300 rounded p-3 mb-3">
                    <p class="font-semibold text-red-800">Error Details:</p>
                    <p class="text-red-700">${error.message}</p>
                    ${lineInfo ? `
                        <p class="text-red-700 mt-2">
                            <strong>Location:</strong> ${lineInfo}
                        </p>
                    ` : ''}
                </div>
                <div class="text-sm text-red-600">
                    <p><strong>File:</strong> ${filename}</p>
                    <p><strong>Common causes:</strong></p>
                    <ul class="list-disc list-inside ml-4 mt-1">
                        <li>Missing comma between objects or array elements</li>
                        <li>Missing closing brackets or braces</li>
                        <li>Unescaped quotes in strings</li>
                        <li>Trailing commas after the last element</li>
                        <li>Invalid characters or encoding issues</li>
                    </ul>
                    <p class="mt-2"><strong>Tip:</strong> Use a JSON validator like jsonlint.com to check your file.</p>
                </div>
            </div>`;
        } else {
            // Unknown error
            errorDetails = `<div class="bg-red-50 border border-red-200 rounded-lg p-4">
                <h3 class="font-bold text-red-800 mb-2">❌ Unexpected Error</h3>
                <p class="text-red-700 mb-3">An unexpected error occurred while processing the file.</p>
                <div class="bg-red-100 border border-red-300 rounded p-3 mb-3">
                    <p class="font-semibold text-red-800">Error Message:</p>
                    <p class="text-red-700">${error.message}</p>
                </div>
                <div class="text-sm text-red-600">
                    <p><strong>File:</strong> ${filename}</p>
                    <p><strong>What to do:</strong> Please check that your file is a valid JSON file with quiz data.</p>
                </div>
            </div>`;
        }

        // Create and show error modal
        this.showErrorModal(errorDetails);
    }

    getLineAndColumnFromError(error, jsonContent) {
        // Try to extract line/column information from SyntaxError
        const match = error.message.match(/at line (\d+) column (\d+)/i) || 
                     error.message.match(/at position (\d+)/i);
        
        if (match) {
            if (match[2]) {
                // Line and column format
                return `Line ${match[1]}, Column ${match[2]}`;
            } else if (match[1]) {
                // Position format - convert to line/column
                const position = parseInt(match[1]);
                const lines = jsonContent.substring(0, position).split('\n');
                const lineNumber = lines.length;
                const columnNumber = lines[lines.length - 1].length + 1;
                return `Line ${lineNumber}, Column ${columnNumber} (Position ${position})`;
            }
        }
        
        return null;
    }

    showErrorModal(content) {
        // Remove existing error modal if present
        const existingModal = document.getElementById('error-modal');
        if (existingModal) {
            existingModal.remove();
        }

        // Create error modal
        const modal = document.createElement('div');
        modal.id = 'error-modal';
        modal.className = 'fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-4';
        modal.innerHTML = `
            <div class="bg-white rounded-lg shadow-xl max-w-2xl w-full max-h-[90vh] overflow-y-auto">
                <div class="p-6">
                    ${content}
                    <div class="mt-6 flex justify-end">
                        <button id="close-error-modal" class="bg-gray-500 hover:bg-gray-600 text-white px-4 py-2 rounded-lg font-medium transition-colors">
                            Close
                        </button>
                    </div>
                </div>
            </div>
        `;

        document.body.appendChild(modal);

        // Add event listener to close modal
        document.getElementById('close-error-modal').addEventListener('click', () => {
            modal.remove();
        });

        // Close modal when clicking outside
        modal.addEventListener('click', (e) => {
            if (e.target === modal) {
                modal.remove();
            }
        });
    }

    showModeSelection() {
        document.getElementById('mode-selection').classList.remove('hidden');
        document.getElementById('quiz-title').textContent = this.quizData.title;
        document.getElementById('quiz-stats').textContent = `${this.quizData.questions.length} questions`;
        document.getElementById('quiz-info').classList.remove('hidden');
    }

    startQuiz(mode) {
        this.currentMode = mode;
        this.userAnswers = {};
        this.shuffledQuestions = this.shuffleQuestions();
        
        document.getElementById('upload-section').classList.add('hidden');
        document.getElementById('mode-selection').classList.add('hidden');
        document.getElementById('quiz-container').classList.remove('hidden');
        
        this.renderQuestions();
    }

    shuffleQuestions() {
        return this.quizData.questions.map((question, index) => {
            const allAnswers = [question.correct_answer, ...question.wrong_answers];
            const shuffledAnswers = this.shuffleArray([...allAnswers]);
            
            return {
                ...question,
                originalIndex: index,
                shuffledAnswers: shuffledAnswers
            };
        });
    }

    shuffleArray(array) {
        const shuffled = [...array];
        for (let i = shuffled.length - 1; i > 0; i--) {
            const j = Math.floor(Math.random() * (i + 1));
            [shuffled[i], shuffled[j]] = [shuffled[j], shuffled[i]];
        }
        return shuffled;
    }

    renderQuestions() {
        const container = document.getElementById('questions-container');
        container.innerHTML = '';

        this.shuffledQuestions.forEach((question, index) => {
            const questionDiv = this.createQuestionElement(question, index);
            container.appendChild(questionDiv);
        });
    }

    createQuestionElement(question, index) {
        const questionDiv = document.createElement('div');
        questionDiv.className = 'question-card bg-white rounded-lg shadow-md p-6';
        questionDiv.id = `question-${index}`;

        const questionHTML = `
            <div class="mb-4">
                <h3 class="text-lg font-semibold text-gray-800 mb-3">
                    Question ${index + 1}: ${question.question}
                </h3>
                ${question.category ? `<span class="inline-block bg-blue-100 text-blue-800 text-xs px-2 py-1 rounded-full">${question.category}</span>` : ''}
            </div>
            <div class="space-y-2">
                ${question.shuffledAnswers.map((answer, answerIndex) => `
                    <label class="answer-option flex items-center p-3 border border-gray-200 rounded-lg cursor-pointer">
                        <input type="radio" name="question-${index}" value="${answer}" class="mr-3 text-blue-600">
                        <span class="text-gray-700">${answer}</span>
                    </label>
                `).join('')}
            </div>
            <div id="feedback-${index}" class="mt-4 hidden">
                <!-- Feedback will be shown here in practice mode -->
            </div>
        `;

        questionDiv.innerHTML = questionHTML;

        // Add event listeners for practice mode
        if (this.currentMode === 'practice') {
            const radioButtons = questionDiv.querySelectorAll('input[type="radio"]');
            radioButtons.forEach(radio => {
                radio.addEventListener('change', () => this.handleAnswerSelection(index, radio.value));
            });
        } else {
            // For exam mode, just store the answer
            const radioButtons = questionDiv.querySelectorAll('input[type="radio"]');
            radioButtons.forEach(radio => {
                radio.addEventListener('change', () => {
                    this.userAnswers[index] = radio.value;
                });
            });
        }

        return questionDiv;
    }

    handleAnswerSelection(questionIndex, selectedAnswer) {
        this.userAnswers[questionIndex] = selectedAnswer;
        const question = this.shuffledQuestions[questionIndex];
        const isCorrect = selectedAnswer === question.correct_answer;
        
        this.showImmediateFeedback(questionIndex, isCorrect, question);
    }

    showImmediateFeedback(questionIndex, isCorrect, question) {
        const feedbackDiv = document.getElementById(`feedback-${questionIndex}`);
        const questionDiv = document.getElementById(`question-${questionIndex}`);
        
        // Highlight the selected answer
        const selectedRadio = questionDiv.querySelector(`input[value="${this.userAnswers[questionIndex]}"]`);
        const selectedLabel = selectedRadio.closest('label');
        
        // Remove previous styling
        questionDiv.querySelectorAll('.answer-option').forEach(label => {
            label.classList.remove('correct-answer', 'incorrect-answer', 'selected-answer');
        });
        
        // Add correct styling
        questionDiv.querySelectorAll('.answer-option').forEach(label => {
            const radio = label.querySelector('input');
            if (radio.value === question.correct_answer) {
                label.classList.add('correct-answer');
            }
        });
        
        // Add selected answer styling if incorrect
        if (!isCorrect) {
            selectedLabel.classList.add('incorrect-answer');
        }
        
        // Show feedback
        const feedbackHTML = `
            <div class="p-4 rounded-lg ${isCorrect ? 'bg-green-50 border border-green-200' : 'bg-red-50 border border-red-200'}">
                <div class="flex items-center mb-2">
                    <span class="font-semibold ${isCorrect ? 'text-green-800' : 'text-red-800'}">
                        ${isCorrect ? '✓ Correct!' : '✗ Incorrect'}
                    </span>
                </div>
                ${!isCorrect ? `<p class="text-gray-700 mb-2"><strong>Correct answer:</strong> ${question.correct_answer}</p>` : ''}
                ${question.explanation ? `<p class="text-gray-700 mb-2"><strong>Explanation:</strong> ${question.explanation}</p>` : ''}
                ${question.references && question.references.length > 0 ? `
                    <div class="text-gray-700">
                        <strong>References:</strong>
                        <ul class="list-disc list-inside mt-1">
                            ${question.references.map(ref => `<li>${this.formatReference(ref)}</li>`).join('')}
                        </ul>
                    </div>
                ` : ''}
            </div>
        `;
        
        feedbackDiv.innerHTML = feedbackHTML;
        feedbackDiv.classList.remove('hidden');
    }

    gradeQuiz() {
        if (Object.keys(this.userAnswers).length < this.shuffledQuestions.length) {
            if (!confirm('You haven\'t answered all questions. Grade anyway?')) {
                return;
            }
        }

        const results = this.calculateResults();
        this.showResults(results);
    }

    calculateResults() {
        let correct = 0;
        let total = this.shuffledQuestions.length;
        const categoryResults = {};
        const incorrectQuestions = [];

        this.shuffledQuestions.forEach((question, index) => {
            const userAnswer = this.userAnswers[index];
            const isCorrect = userAnswer === question.correct_answer;
            
            if (isCorrect) {
                correct++;
            } else {
                incorrectQuestions.push({ question, index, userAnswer });
            }

            // Track by category
            const category = question.category || 'General';
            if (!categoryResults[category]) {
                categoryResults[category] = { correct: 0, total: 0 };
            }
            categoryResults[category].total++;
            if (isCorrect) {
                categoryResults[category].correct++;
            }
        });

        const percentage = Math.round((correct / total) * 100);

        return {
            correct,
            incorrect: total - correct,
            total,
            percentage,
            categoryResults,
            incorrectQuestions
        };
    }

    showResults(results) {
        document.getElementById('quiz-container').classList.add('hidden');
        document.getElementById('results-section').classList.remove('hidden');

        // Summary
        const summaryHTML = `
            <div class="bg-blue-50 border border-blue-200 rounded-lg p-4 text-center">
                <h4 class="font-semibold text-blue-800">Score</h4>
                <p class="text-2xl font-bold text-blue-900">${results.percentage}%</p>
            </div>
            <div class="bg-green-50 border border-green-200 rounded-lg p-4 text-center">
                <h4 class="font-semibold text-green-800">Correct</h4>
                <p class="text-2xl font-bold text-green-900">${results.correct}</p>
            </div>
            <div class="bg-red-50 border border-red-200 rounded-lg p-4 text-center">
                <h4 class="font-semibold text-red-800">Incorrect</h4>
                <p class="text-2xl font-bold text-red-900">${results.incorrect}</p>
            </div>
        `;
        document.getElementById('results-summary').innerHTML = summaryHTML;

        // Category breakdown
        const categoryHTML = Object.entries(results.categoryResults)
            .map(([category, stats]) => {
                const percentage = Math.round((stats.correct / stats.total) * 100);
                return `
                    <div class="flex justify-between items-center p-3 bg-gray-50 rounded-lg">
                        <span class="font-medium text-gray-700">${category}</span>
                        <div class="text-right">
                            <span class="font-semibold">${stats.correct}/${stats.total}</span>
                            <span class="text-sm text-gray-600 ml-2">(${percentage}%)</span>
                        </div>
                    </div>
                `;
            }).join('');
        document.getElementById('category-results').innerHTML = categoryHTML;

        this.currentResults = results;
    }

    showReview(type) {
        const container = document.getElementById('review-container');
        container.classList.remove('hidden');
        container.innerHTML = '';

        const questionsToReview = type === 'all' 
            ? this.shuffledQuestions.map((q, index) => ({ question: q, index, userAnswer: this.userAnswers[index] }))
            : this.currentResults.incorrectQuestions;

        questionsToReview.forEach(({ question, index, userAnswer }) => {
            const reviewDiv = this.createReviewQuestionElement(question, index, userAnswer);
            container.appendChild(reviewDiv);
        });

        // Scroll to review section
        container.scrollIntoView({ behavior: 'smooth' });
    }

    createReviewQuestionElement(question, index, userAnswer) {
        const questionDiv = document.createElement('div');
        questionDiv.className = 'bg-white rounded-lg shadow-md p-6';

        const isCorrect = userAnswer === question.correct_answer;
        const statusClass = isCorrect ? 'text-green-600' : 'text-red-600';
        const statusIcon = isCorrect ? '✓' : '✗';

        const questionHTML = `
            <div class="mb-4">
                <div class="flex items-center justify-between mb-2">
                    <h3 class="text-lg font-semibold text-gray-800">
                        Question ${index + 1}: ${question.question}
                    </h3>
                    <span class="${statusClass} font-bold text-xl">${statusIcon}</span>
                </div>
                ${question.category ? `<span class="inline-block bg-blue-100 text-blue-800 text-xs px-2 py-1 rounded-full">${question.category}</span>` : ''}
            </div>
            
            <div class="space-y-2 mb-4">
                ${question.shuffledAnswers.map(answer => {
                    let classes = 'flex items-center p-3 border rounded-lg';
                    if (answer === question.correct_answer) {
                        classes += ' bg-green-50 border-green-200';
                    } else if (answer === userAnswer && !isCorrect) {
                        classes += ' bg-red-50 border-red-200';
                    } else {
                        classes += ' border-gray-200';
                    }
                    
                    return `
                        <div class="${classes}">
                            <span class="mr-3">
                                ${answer === question.correct_answer ? '✓' : answer === userAnswer && !isCorrect ? '✗' : '○'}
                            </span>
                            <span class="text-gray-700">${answer}</span>
                        </div>
                    `;
                }).join('')}
            </div>

            <div class="space-y-3">
                ${userAnswer ? `
                    <div>
                        <strong class="text-gray-700">Your answer:</strong> 
                        <span class="${isCorrect ? 'text-green-600' : 'text-red-600'}">${userAnswer}</span>
                    </div>
                ` : '<div class="text-gray-500">No answer selected</div>'}
                
                <div>
                    <strong class="text-gray-700">Correct answer:</strong> 
                    <span class="text-green-600">${question.correct_answer}</span>
                </div>
                
                ${question.explanation ? `
                    <div>
                        <strong class="text-gray-700">Explanation:</strong>
                        <p class="text-gray-600 mt-1">${question.explanation}</p>
                    </div>
                ` : ''}
                
                ${question.references && question.references.length > 0 ? `
                    <div>
                        <strong class="text-gray-700">References:</strong>
                        <ul class="list-disc list-inside mt-1 text-gray-600">
                            ${question.references.map(ref => `<li>${this.formatReference(ref)}</li>`).join('')}
                        </ul>
                    </div>
                ` : ''}
            </div>
        `;

        questionDiv.innerHTML = questionHTML;
        return questionDiv;
    }

    restartQuiz() {
        // Reset everything
        this.quizData = null;
        this.userAnswers = {};
        this.currentMode = null;
        this.shuffledQuestions = [];
        this.currentResults = null;

        // Reset UI
        document.getElementById('upload-section').classList.remove('hidden');
        document.getElementById('mode-selection').classList.add('hidden');
        document.getElementById('quiz-info').classList.add('hidden');
        document.getElementById('quiz-container').classList.add('hidden');
        document.getElementById('results-section').classList.add('hidden');
        document.getElementById('review-container').classList.add('hidden');
        
        // Clear file input
        document.getElementById('quiz-file').value = '';
        
        // Clear containers
        document.getElementById('questions-container').innerHTML = '';
        document.getElementById('results-summary').innerHTML = '';
        document.getElementById('category-results').innerHTML = '';
        document.getElementById('review-container').innerHTML = '';
    }
}

// Initialize the quiz application
document.addEventListener('DOMContentLoaded', () => {
    new QuizGrader();
});
