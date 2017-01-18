require 'sinatra'
require 'rubygems'
require 'csv'
require 'pg'
require_relative 'password_class.rb'

load "./local_env.rb" if File.exists?("./local_env.rb")

db_params={
  host: ENV['host'],
  port: ENV['port'],
  dbname: ENV['db_name'],
  user: ENV['user'],
  password: ENV['password']
}

db= PG::Connection.new(db_params)

enable :sessions

def write_to_pretest_csv(fullname, teacher, grade, question_text, answer_text, pretest_input, test_date)
    CSV.open("./public/img/pretest.csv", "a") do |row|
      row << [fullname, teacher, grade, question_text, answer_text, pretest_input, test_date]
    end
end

def write_to_posttest_csv(fullname, teacher, grade, question_text, answer_text, posttest_input, test_date)
    CSV.open("./public/img/posttest.csv", "a") do |row|
      row << [fullname, teacher, grade, question_text, answer_text, posttest_input, test_date]
    end
end

def write_to_compare_csv(fullname, test_date, question_text, pre_answer, post_answer)
    CSV.open("./public/img/compare_results.csv", "a") do |row|
      row << [fullname, test_date, question_text, pre_answer, post_answer]
    end
end

def determine_student_id(db, name, teacher)
  student_id_hash = db.exec("SELECT student_id from public.users WHERE full_name = '#{name}' and teacher = '#{teacher}'")

  student_id_hash[0]["student_id"]
end

get '/' do
    @title = 'Home Page'
    
    users = db.exec("SELECT * FROM public.users")
    session[:full_name] = params[:full_name]

    erb :user_registration, :locals => {:users => users}
end

post '/user_register' do
  session[:full_name] = params[:full_name]
  session[:teacher] = params[:teacher]
  session[:grade] = params[:grade]
  password = params[:password]
  
  db.exec("INSERT INTO public.users (full_name, teacher, grade)
    VALUES ('#{session[:full_name]}', '#{session[:teacher]}', '#{session[:grade]}')")

  session[:student_id] = determine_student_id(db, session[:full_name], session[:teacher])

  if password == "greenplanetgames"
    redirect '/admin'
  elsif password == "123abc"
    redirect '/pre_test'
  else
    redirect '/'
  end
end

get '/pre_test' do
  @title = 'Pre-Test'
  session[:student_id] = session[:student_id]
  session[:full_name] = session[:full_name]
  session[:teacher] = session[:teacher]

  questions_answers = db.exec("select questions.question_id, image, question_text, answer_id, answer_text From questions, answers Where questions.question_id = answers.question_id and questions.active");

  erb :pre_test, :locals => {:full_name => session[:full_name], :student_id => session[:student_id], :questions_answers => questions_answers}
end

post '/pre_test' do
  session[:student_id] = session[:student_id]
  session[:full_name] = session[:full_name]
  session[:teacher] = session[:teacher]
  session[:grade] = session[:grade]
  session[:questions_answers] = params[:questions_answers]
  session[:pre_test_text] = params[:pre_test_text]

  params[:answers].each do |question|
  
    test_date = Time.now

    db.exec("INSERT INTO public.pretest (student_id, test_date, question_id, answer_id, pre_test_text)
    VALUES ('#{session[:student_id]}','#{test_date}','#{question[0]}', '#{question[1].to_s}', '#{session[:pre_test_text]}')")

    db.exec("UPDATE public.pretest SET pre_answer = answers.answer_text FROM answers, users, questions WHERE answers.answer_id = '#{question[1].to_s}' AND pretest.student_id = '#{session[:student_id]}' AND pretest.question_id = '#{question[0]}'")

    db.exec("INSERT INTO public.results (student_id, test_date, question_id, pre_answer)
    VALUES ('#{session[:student_id]}','#{test_date}', '#{question[0]}', (SELECT answer_text FROM answers WHERE answers.answer_id = '#{question[1].to_s}'))")

  end
  redirect 'play_game'
end

get '/play_game' do
  @title = 'Biogamecrafter'
  session[:student_id] = session[:student_id]
  session[:full_name] = session[:full_name]
  session[:teacher] = session[:teacher]
  session[:grade] = session[:grade]
  session[:questions_answers] = params[:questions_answers]
  session[:pre_test_text] = session[:pre_test_text]
  erb :play_game, :locals => {:full_name => session[:full_name], :student_id => session[:student_id], :questions_answers => session[:questions_answers]}
end

post '/play_game' do
  redirect 'post_test'
end

get '/post_test' do
  @title = 'Post-Test'
  session[:student_id] = session[:student_id]
  session[:full_name] = session[:full_name]
  session[:teacher] = session[:teacher]
  session[:grade] = session[:grade]
  session[:questions_answers] = session[:questions_answers]
  session[:pre_test_text] = session[:pre_test_text]
  
  questions_answers = db.exec("select questions.question_id, image, question_text, answer_id, answer_text From questions, answers Where questions.question_id = answers.question_id and questions.active");

  erb :post_test, :locals => {:full_name => session[:full_name], :student_id => session[:student_id], :questions_answers => questions_answers}
end

post '/post_test' do
  session[:student_id] = session[:student_id]
  session[:full_name] = session[:full_name]
  session[:teacher] = session[:teacher]
  session[:grade] = session[:grade]
  session[:questions_answers] = session[:questions_answers]
  session[:pre_test_text] = session[:pre_test_text]
  session[:post_test_text] = params[:post_test_text]

    params[:answers].each do |question|
  
    test_date = Time.now

      db.exec("INSERT INTO public.posttest (student_id, test_date, question_id, answer_id, post_test_text, post_answer)
        VALUES ('#{session[:student_id]}','#{test_date}','#{question[0]}', '#{question[1].to_s}', '#{session[:post_test_text]}', (SELECT answer_text FROM answers WHERE answers.answer_id = '#{question[1].to_s}'))")
      
      db.exec("UPDATE public.results SET post_answer = answers.answer_text FROM answers WHERE answers.answer_id = '#{question[1].to_s}' AND results.student_id = '#{session[:student_id]}' AND results.question_id = '#{question[0]}'")
        
     end
     redirect 'logoff'
end

get "/logoff" do
  erb :logoff
  end


get '/export' do
  erb :export
end

post '/pretest_export' do
  pretest_export = db.exec("SELECT users.full_name, users.teacher, users.grade, questions.question_text, answers.answer_text, pretest.pre_test_text, pretest.test_date FROM users, questions, answers, pretest WHERE users.student_id = pretest.student_id AND questions.question_id = pretest.question_id AND answers.answer_id = pretest.answer_id")

  CSV.open("./public/img/pretest.csv", "w") do |row|
      row << ['full_name', 'teacher', 'grade', 'question_text', 'answer_text', 'pre_test_text', 'test_date']
  end
  
  pretest_export.each do |row|
    write_to_pretest_csv(row['full_name'], row['teacher'], row['grade'], row['question_text'], row['answer_text'], row ['pre_test_text'], row['test_date'])
  end

  send_file('./public/img/pretest.csv', :disposition => 'attachment', :filename => File.basename('pretest.csv'))

  redirect '/export'
end

post '/posttest_export' do
  posttest_export = db.exec("SELECT users.full_name, users.teacher, users.grade, questions.question_text, answers.answer_text, posttest.post_test_text, posttest.test_date FROM users, questions, answers, posttest WHERE users.student_id = posttest.student_id AND questions.question_id = posttest.question_id AND answers.answer_id = posttest.answer_id")

  CSV.open("./public/img/posttest.csv", "w") do |row|
      row << ['full_name', 'teacher', 'grade', 'question_text', 'answer_text', 'post_test_text', 'test_date']
  end
  
  posttest_export.each do |row|
    write_to_posttest_csv(row['full_name'], row['teacher'], row['grade'], row['question_text'], row['answer_text'], row['post_test_text'], row['test_date'])
  end

  send_file('./public/img/posttest.csv', :disposition => 'attachment', :filename => File.basename('posttest.csv'))
end

post '/compare_results' do
  compare_export = db.exec("SELECT users.full_name, results.test_date, questions.question_text, results.pre_answer, results.post_answer FROM users, questions, results WHERE results.student_id = users.student_id AND results.question_id = questions.question_id ORDER BY users.full_name, results.question_id")

  CSV.open("./public/img/compare_results.csv", "w") do |row|
      row << ['full_name', 'test_date', 'question_text', 'pre_answer', 'post_answer']
  end
  
  compare_export.each do |row|
    write_to_compare_csv(row['full_name'], row['test_date'], row['question_text'], row['pre_answer'], row ['post_answer'])
  end

  send_file('./public/img/compare_results.csv', :disposition => 'attachment', :filename => File.basename('compare_results.csv'))

  redirect '/export'
end

get '/admin' do
  erb :admin
end

get '/admin1' do
  session[:student_id] = session[:student_id]
  session[:full_name] = session[:full_name]
  session[:teacher] = session[:teacher]
  session[:grade] = session[:grade]
  session[:questions_answers] = session[:questions_answers]
  session[:post_test_text] = session[:post_test_text]
 
  admin_questions = db.exec("select questions.question_id,question_text,active From questions ORDER BY question_id ASC");

  erb :admin1, :locals => {:full_name => session[:full_name], :student_id => session[:student_id], :admin_questions => admin_questions}
end

post '/admin1' do
  
  monkey_tail = params[:active]
  # puts "3rd question is #{monkey_tail[2]}"

  monkey_tail.each_with_index do |monkey_tail, i|
    # puts "#{i}"
    val = params[:active][i]
    # puts "#{val}"
      sql = "UPDATE public.questions SET active = '#{val}' WHERE questions.question_id = #{i} + 1"
      # puts sql
      db.exec(sql)
  end

# puts "active is #{monkey_tail} and its class is #{monkey_tail.class}"
   
redirect '/submissions'
end


get '/submissions' do 

    erb :admin_logoff

end 

