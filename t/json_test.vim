describe 'json parsing'
    before
        let g:analog#test#shifts1 = '[{"start":"2016-04-27T09:00:00","end":"2016-04-27T11:30:00","employees":[{"firstName": "A", "lastName": "B"}]}]'

        let g:analog#test#shifts2 = '[{"start":"2016-04-27T09:30:00+02:00","end":"2016-04-27T11:30:00+02:00","employees":[]}]'

        let g:analog#test#shifts3 = '[{"open": "2016-04-27T09:30:00"}]'
    end

    after
        unlet g:analog#test#shifts1
        unlet g:analog#test#shifts2
        unlet g:analog#test#shifts3
    end

    it 'should parse the open status json without error and yield the correct results'
        Expect analog#json#parse_open_status('{"open": true}') == 1
        Expect analog#json#parse_open_status('{"open": false}') == 0
        Expect analog#json#parse_open_status('{"open": "none"}') == -1
        Expect analog#json#parse_open_status('') == -1
        Expect analog#json#parse_open_status('["this", "should", "fail"]') == -1
        Expect analog#json#parse_open_status('}{') == -1
    end

    it 'should parse the employees and yield the correct results for well-formatted json'
        Expect analog#json#parse_employees(g:analog#test#shifts1, 'employees') == [['A B']]
        Expect analog#json#parse_employees(g:analog#test#shifts2, 'employees') == [[]]
        Expect analog#json#parse_employees('', 'employees') == []
    end

    it 'should throw an error for ill-formatted json or json where the employees are missing'
        let expected_error_msg = '^Vim(echoerr):vim-analog: Failed to parse json for employees'
        Expect expr { analog#json#parse_employees('}{', 'employees') }  to_throw expected_error_msg
        Expect expr { analog#json#parse_employees('z<o', 'employees') } to_throw expected_error_msg
    end

    it 'should parse the open hours and yield the correct results'
        Expect analog#json#parse_open_hours(g:analog#test#shifts1) == [['09:00', '11:30']]
        Expect analog#json#parse_open_hours(g:analog#test#shifts2) == [['09:30', '11:30']]
        Expect analog#json#parse_open_hours('') == []
        Expect analog#json#parse_open_hours('{"a": 1}') == []
        Expect analog#json#parse_open_hours('}{') == []
    end

    it 'should throw an error for ill-formatted json or json where the open hours are incomplete'
        let expected_error_msg = '^Vim(echoerr):vim-analog: Failed to parse json for open hours'
        Expect expr { analog#json#parse_open_hours(g:analog#test#shifts3) } to_throw expected_error_msg
    end
end
