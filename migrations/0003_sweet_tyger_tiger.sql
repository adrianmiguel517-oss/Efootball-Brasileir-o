ALTER TABLE `clubs` ADD `tournament_id` text;--> statement-breakpoint
ALTER TABLE `external` ADD `season_id` text REFERENCES seasons(id);--> statement-breakpoint
ALTER TABLE `external` ADD `tournament_id` text;--> statement-breakpoint
ALTER TABLE `matches` ADD `tournament_id` text;