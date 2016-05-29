describe 'vim-analog'
    before
    end

    it 'should return the expected difference between two time points'
        Expect analog#time#diff([18, 26], [17, 30]) == [0, -56]
        Expect analog#time#diff([17, 30], [18, 26]) == [0, 56]
        Expect analog#time#diff([12, 30], [13, 30]) == [1, 0]
        Expect analog#time#diff([13, 30], [12, 30]) == [-1, 0]
        Expect analog#time#diff([14, 30], [14, 32]) == [0, 2]
        Expect analog#time#diff([14, 32], [14, 30]) == [0, -2]
        Expect analog#time#diff([11, 34], [18, 01]) == [6, 27]
        Expect analog#time#diff([18, 01], [11, 34]) == [-6, -27]
        Expect analog#time#diff([13, 00], [13, 00]) == [0, 0]
        Expect analog#time#diff([14, 24], [24, 34]) == [10, 10]
        Expect analog#time#diff([24, 34], [14, 24]) == [-10, -10]
        Expect analog#time#diff([17, 15], [09, 47]) == [-7, -28]
        Expect analog#time#diff([09, 47], [17, 15]) == [7, 28]
    end

    it 'should return the correct index for an time interval'
        Expect analog#time#in_interval([15, 46], ['9:30', '11:30', '14:30', '17:30']) == 1
        Expect analog#time#in_interval([09, 31], ['9:30', '11:30', '14:30', '17:30']) == 0
        Expect analog#time#in_interval([13, 51], ['9:30', '11:30', '14:30', '17:30']) == -1
        Expect analog#time#in_interval([09, 29], ['9:30', '11:30', '14:30', '17:30']) == -1
        Expect analog#time#in_interval([22, 25], ['9:30', '11:30', '14:30', '17:30']) == -1
        Expect analog#time#in_interval([12, 00], ['12:00', '12:00']) == 0
    end

    it 'should convert a timepoint to seconds correctly'
        Expect analog#time#time_to_seconds([12, 40]) == 45600
        Expect analog#time#time_to_seconds([14, 01]) == 50460
        Expect analog#time#time_to_seconds([05, 59]) == 21540
        Expect analog#time#time_to_seconds([22, 15]) == 80100
        Expect analog#time#time_to_seconds([08, 30]) == 30600
    end

    it 'should convert seconds to a timepoint correctly'
        Expect analog#time#seconds_to_time(45600) == [12, 40]
        Expect analog#time#seconds_to_time(50460) == [14, 01]
        Expect analog#time#seconds_to_time(21540) == [05, 59]
        Expect analog#time#seconds_to_time(80100) == [22, 15]
        Expect analog#time#seconds_to_time(30600) == [08, 30]
    end
end
