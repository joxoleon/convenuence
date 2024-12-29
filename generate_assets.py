import os

colors = [
    {"name": "PrimaryBackground", "light": "#F8F8F8", "dark": "#1C1C1E"},
    {"name": "CardBackground", "light": "#FFFFFF", "dark": "#2C2C2E"},
    {"name": "PrimaryText", "light": "#1C1C1E", "dark": "#D1D1D6"},
    {"name": "SecondaryText", "light": "#8E8E93", "dark": "#8E8E93"},
    {"name": "AccentBlue", "light": "#007AFF", "dark": "#64D2FF"},
    {"name": "AccentPurple", "light": "#AF52DE", "dark": "#8674E4"},
    {"name": "MutedTeal", "light": "#5AC8FA", "dark": "#5AC8FA"},
    {"name": "Divider", "light": "#E5E5EA", "dark": "#3A3A3C"},
]

def hex_to_srgb(hex_value):
    r = int(hex_value[1:3], 16) / 255
    g = int(hex_value[3:5], 16) / 255
    b = int(hex_value[5:7], 16) / 255
    return {"red": f"{r:.3f}", "green": f"{g:.3f}", "blue": f"{b:.3f}", "alpha": "1.000"}

# Correct the output directory path
output_dir = "./ConVenuence/ConVenuence/Assets.xcassets/Colors"
os.makedirs(output_dir, exist_ok=True)

for color in colors:
    color_dir = os.path.join(output_dir, f"{color['name']}.colorset")
    os.makedirs(color_dir, exist_ok=True)

    light_rgb = hex_to_srgb(color["light"])
    dark_rgb = hex_to_srgb(color["dark"])

    json_content = {
        "info": {"version": 1, "author": "xcode"},
        "colors": [
            {
                "idiom": "universal",
                "color": {
                    "color-space": "srgb",
                    "components": {
                        "red": light_rgb["red"],
                        "green": light_rgb["green"],
                        "blue": light_rgb["blue"],
                        "alpha": "1.000"
                    }
                }
            },
            {
                "idiom": "universal",
                "color": {
                    "color-space": "srgb",
                    "components": {
                        "red": dark_rgb["red"],
                        "green": dark_rgb["green"],
                        "blue": dark_rgb["blue"],
                        "alpha": "1.000"
                    }
                },
                "appearances": [
                    {
                        "appearance": "luminosity",
                        "value": "dark"
                    }
                ]
            }
        ]
    }

    with open(os.path.join(color_dir, "Contents.json"), "w") as f:
        import json

        json.dump(json_content, f, indent=4)
