class Stats::Counts
  #TODO: write tests for all methods!!!

  # Users-participants of BigYear with the number of species in Big Year (species_count)
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
                                   (b.species_id IS NOT NULL) AND
                                   (EXTRACT(YEAR FROM b.timestamp) = ?) AND
                                   (EXTRACT(YEAR FROM b.created_at) = ?) AND
                                   (b.expert_id IS NOT NULL)
              WHERE (u.big_year IS TRUE)
              GROUP BY u.id, b.species_id
          ) t1 ON u.id = t1.user_id
          GROUP BY u.id
      ) t2 ON t2.user_id = users.id
      ORDER BY t2.species_count DESC
      ",
      year,
      year
    ])

    User.find_by_sql(sql)
  end

  # The amount of user's species in BigYear for some year
  def big_year_user_species_count(user_id, year = Time.zone.now.year)
    return 0 unless User.find(user_id).big_year
    Bird.published.known.approved
        .where(user_id: user_id)
        .where("EXTRACT(year FROM timestamp) = ?", year)
        .where("EXTRACT(year FROM created_at) = ?", year)
        .select(:species_id).distinct(:species_id)
        .size
  end

  #TODO:: rewrite, big_year???
  def big_year_users_count
    User.where(big_year: true).size
  end

  #TODO: rewrite, add params validation, check when user doesn't have any photo
  def big_year_user_rating(user_id, year = Time.zone.now.year)
    return 0 unless User.find(user_id).big_year # ???
    index = big_year_users_species_count(year).find_index { |user| user.id == user_id }
    index ? index + 1 : 0
  end

  # Total amount of species met by some user
  def user_species(user_id)
    Species.joins(:birds)
        .where(birds: {published: true, user_id: user_id})
        .where("birds.expert_id IS NOT NULL")
        .distinct.order(:name_ru)
  end

end
