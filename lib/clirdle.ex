defmodule Clirdle do
  alias Clirdle.{Guesses, Words}

  @rounds ["1st", "2nd", "3rd", "4th", "5th", "6th (last)"]

  def main(args) do
    {options, _, _} = OptionParser.parse(args, switches: [light: :boolean])

    new_game = %{
      word: Words.get_todays_word(),
      guesses: [],
      share: [],
      options: options
    }

    play(new_game)
  end

  defp play(%{guesses: guesses, word: word, share: share}) when length(guesses) == 6,
    do: print_with_share("Game Over\n(the word was \"#{word}\")", share)

  defp play(%{guesses: guesses} = game),
    do:
      guesses |> length() |> prompt_for_guess() |> advance_if_valid_guess(game) |> check_for_win()

  defp prompt_for_guess(round_index) do
    round = Enum.at(@rounds, round_index)
    "Please enter your #{round} guess: " |> IO.gets() |> String.trim()
  end

  defp advance_if_valid_guess(
         guess,
         %{word: word, guesses: guesses, share: share, options: options} = game
       ) do
    game_result =
      if Guesses.is_valid_guess?(guess) do
        {feedback, to_share} = create_guess_feedback(word, guess, options)
        guesses_updated = guesses ++ [Enum.join(feedback, " ")]
        guesses_updated |> Enum.join("\n") |> IO.puts()
        IO.puts("")
        share_updated = share ++ [to_share]
        Map.merge(game, %{guesses: guesses_updated, share: share_updated})
      else
        IO.puts("invalid guess")
        game
      end

    {game_result, guess}
  end

  defp check_for_win({%{word: word, share: share}, guess})
       when guess == word,
       do: print_with_share("You've won!", share)

  defp check_for_win({game, _}), do: play(game)

  defp create_guess_feedback(word, guess, options) do
    word_charlist = String.to_charlist(word)
    word_mapset = MapSet.new(word_charlist)

    guess
    |> String.to_charlist()
    |> Enum.with_index()
    |> Enum.map(fn {l, i} ->
      l_as_string = to_string([l])

      cond do
        l == Enum.at(word_charlist, i) ->
          [format_as_correct(l_as_string), "🟩"]

        MapSet.member?(word_mapset, l) ->
          [format_as_in_word(l_as_string), "🟨"]

        true ->
          light? = Keyword.get(options, :light)

          [
            format_as_not_in_word(l_as_string, light?),
            if(light?, do: "⬜", else: "⬛")
          ]
      end
    end)
    |> Enum.zip()
    |> Enum.map(&Tuple.to_list/1)
    |> List.to_tuple()
  end

  defp format_as_correct(letter),
    do: IO.ANSI.green_background() <> IO.ANSI.black() <> letter <> IO.ANSI.reset()

  defp format_as_in_word(letter),
    do: IO.ANSI.yellow_background() <> IO.ANSI.black() <> letter <> IO.ANSI.reset()

  defp format_as_not_in_word(letter, _light? = true),
    do: IO.ANSI.white_background() <> IO.ANSI.black() <> letter <> IO.ANSI.reset()

  defp format_as_not_in_word(letter, _light?),
    do: IO.ANSI.black_background() <> IO.ANSI.white() <> letter <> IO.ANSI.reset()

  defp print_with_share(message, share) do
    IO.puts(message)
    share |> Enum.join("\n") |> IO.puts()
  end
end
