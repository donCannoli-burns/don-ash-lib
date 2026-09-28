package ash

import "context"

func (c *Client) MyName(ctx context.Context) (string, error) {
	v, err := c.Call(ctx, "myName")
	if err != nil {
		return "", err
	}
	return v.String()
}

func (c *Client) MyMeat(ctx context.Context) (int64, error) {
	v, err := c.Call(ctx, "myMeat")
	if err != nil {
		return 0, err
	}
	return v.Int64()
}

func (c *Client) MyAdventures(ctx context.Context) (int64, error) {
	v, err := c.Call(ctx, "myAdventures")
	if err != nil {
		return 0, err
	}
	return v.Int64()
}

func (c *Client) AvailableAmount(ctx context.Context, item Item) (int64, error) {
	v, err := c.Call(ctx, "availableAmount", item)
	if err != nil {
		return 0, err
	}
	return v.Int64()
}

func (c *Client) HaveSkill(ctx context.Context, skill Skill) (bool, error) {
	v, err := c.Call(ctx, "haveSkill", skill)
	if err != nil {
		return false, err
	}
	return v.Bool()
}

func (c *Client) NumericModifier(ctx context.Context, modifier string) (float64, error) {
	v, err := c.Call(ctx, "numericModifier", modifier)
	if err != nil {
		return 0, err
	}
	return v.Float64()
}
