describe 'vim-analog'
    before
        let g:analog#test#shifts1 = '[{"Open":"2016-04-27T09:00:00+02:00","Close":"2016-04-27T11:30:00+02:00","Employees":["A","B"]},' .
            \ '{"Open":"2016-04-27T14:30:00+02:00","Close":"2016-04-27T17:30:00+02:00","Employees":["C","D","E"]}]'

        let g:analog#test#shifts2 = '[{"Open":"2016-04-27T09:30:00+02:00","Close":"2016-04-27T11:30:00+02:00","Employees":[]},' .
            \ '{"Open":"2016-04-27T11:30:00+02:00","Close":"2016-04-27T17:00:00+02:00","Employees":[]}]'

        let g:analog#test#shifts3 = '[{"Open": "2016-04-27T09:30:00+02:00"}]'
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

    it 'should parse the employees without error and yield the correct results'
        Expect analog#json#parse_json_employees(g:analog#test#shifts1) == [['A', 'B'], ['C', 'D', 'E']]
        Expect analog#json#parse_json_employees(g:analog#test#shifts2) == [[], []]
        Expect analog#json#parse_json_employees('') == []
        Expect analog#json#parse_json_employees('{"a": 1}') == []
        Expect analog#json#parse_json_employees('}{') == []

        let expected_error_msg = '^Vim(echoerr):vim-analog: Failed to parse json for employees'
        Expect expr { analog#json#parse_json_employees(g:analog#test#shifts3)} } to_throw expected_error_msg
    end

    it 'should parse the open hours without error and yield the correct results'
        Expect analog#json#parse_json_open_hours(g:analog#test#shifts1) == ['09:00', '11:30', '14:30', '17:30']
        Expect analog#json#parse_json_open_hours(g:analog#test#shifts2) == ['09:30', '11:30', '11:30', '17:00']
        Expect analog#json#parse_json_open_hours('') == []
        Expect analog#json#parse_json_open_hours('{"a": 1}') == []
        Expect analog#json#parse_json_open_hours('}{') == []

        let expected_error_msg =  '^Vim(echoerr):vim-analog: Failed to parse json for open hours'
        Expect expr { analog#json#parse_json_open_hours(g:analog#test#shifts3) } to_throw expected_error_msg
    end
end
