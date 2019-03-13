class Question
  def self.all
    [
      {
        id: 1,
        content: 'How long are you planning to live in Sydney?',
        options: [
          {
            id: 1,
            content: '1-2 months',
            payload: 'SELECT_TIME_1_2_MONTHS'
          }, {
            id: 2,
            content: '3-5 months',
            payload: 'SELECT_TIME_3_5_MONTHS'
          }, {
            id: 3,
            content: '6 months',
            payload: 'SELECT_TIME_6_MONTHS'
          }, {
            id: 4,
            content: '1 year +',
            payload: 'SELECT_TIME_1_YEAR_PLUS'
          }
        ]
      }, {
        id: 2,
        content: 'What type of room do you want to rent?',
        options: [
          {
            id: 1,
            content: 'Twin-share',
            payload: 'SELECT_ROM_TYPE_TWIN_SHARE'
          }, {
            id: 2,
            content: 'Private',
            payload: 'SELECT_ROM_TYPE_PRIVATE'
          }, {
            id: 3,
            content: 'Couple (double bed)',
            payload: 'SELECT_ROM_TYPE_COUPLE'
          }
        ]
      }
    ]
  end

  def self.action_payloads
    all.map { |q| q[:options].map { |o| o[:payload]} }.flatten
  end
end
