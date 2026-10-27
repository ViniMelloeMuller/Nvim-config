return {
	"windwp/nvim-autopairs",
	event = "InsertEnter",
	opts = {},
	config = function(_, opts)
		local npairs = require("nvim-autopairs")
		local Rule = require("nvim-autopairs.rule")
		local cond = require("nvim-autopairs.conds")

		npairs.setup(opts)

		npairs.add_rules({
			Rule("$", "$", { "tex", "latex", "plaintex" })
				:with_pair(cond.not_after_regex("%%"))
				:with_pair(cond.not_before_regex([[\]], 1))
				:with_move(cond.none())
				:with_cr(cond.none()),
			Rule("$$", "$$", { "tex", "latex", "plaintex" })
				:with_pair(cond.not_after_regex("%%"))
				:with_pair(cond.not_before_regex([[\]], 1)),
		})
	end,
}
