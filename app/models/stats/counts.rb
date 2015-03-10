class Stats::Counts
  #TODO: write tests for all methods!!!

  def big_year_users_species_count(year = Time.zone.now.year)
    sql = ActiveRecord::Base.send(:sanitize_sql_array, ["
      SELECT users.*, t2.species_count
      FROM users
      INNER JOIN (
          SELECT
            u.id user_id,
            count(t1.species_id) species_count
          FROM users u
          INNER JOIN(
              SELECT
                u.id user_id,
                b.species_id
              FROM users u
              LEFT JOIN birds b ON (b.user_id = u.id) AND
                                   (b.published = 'true') AND
                                   (EXTRACT(YEAR FROM b.timestamp) = ?)
              WHERE (u.big_year IS TRUE)
              GROUP BY u.id, b.species_id
          ) t1 ON u.id = t1.user_id
          GROUP BY u.id
      ) t2 ON t2.user_id = users.id
      ORDER BY t2.species_count DESC
      ",
      year
    ])

    User.find_by_sql(sql)
  end

  def big_year_user_species_count(user_id, year = Time.zone.now.year)
    Bird.where(user_id: user_id).where("EXTRACT(year FROM timestamp) = ?", year).select(:species_id).distinct(:species_id).size
  end

  def big_year_users_count
    User.where(big_year: true).size
  end

  #TODO: rewrite, add params validation, check when user doesn't have any photo
  def big_year_user_rating(user_id, year = Time.zone.now.year)
    return 0 unless User.find(user_id).big_year # ???
    index = big_year_users_species_count(year).find_index { |user| user.id == user_id }
    index ? index + 1 : 0
  end

  def big_year_species(year = Time.zone.now.year)
    Species.joins(birds: :user)
      .where(birds: { :published => 'true' })
      .where(users: { :big_year => 'true' })
      .where('EXTRACT(year FROM birds.timestamp) = ?', year)
      .distinct('species.id')
      .order('species.name_ru')
  end

  def birds_species_count
    Species.joins(:birds).where(birds: {published: true}).select(:id).distinct.count
  end
end
