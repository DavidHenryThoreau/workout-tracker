package apptranslations

import (
	"testing"

	"github.com/stretchr/testify/require"
)

func TestEmbedded(t *testing.T) {
	c, err := FS().Open("messages.json")
	require.NoError(t, err)

	s, err := c.Stat()
	require.NoError(t, err)

	require.NotZero(t, s.Size())
}
