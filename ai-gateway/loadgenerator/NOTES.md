## Install dependencies
pip install -r requirements.txt


## Run the load generator
python load_simulation.py


Example client:

TOKEN="eyJhbGciOiJSUzI1NiIsInR5cGUiOiJKV1QifQ.eyJpc3MiOiJzb2xvLmlvIiwib3JnIjoic29sby5pbyIsIm5hbWUiOiJKb2huIERvZSIsInN1YiI6Impkb2UxIiwidGVhbSI6InJldHVybnMiLCJsbG1zIjp7Im9sbGFtYSI6WyJxd2VuLTAuNWIiXX19.SGepFax_pebgIxP1ilT_AynOu5Y-kgg7AI5iR8iGR3HhfYYFBhs9tH9BAZyVgXLS99ZEZrIR5bhwj7TbNqF09TQOeUsL06ersMtJldHibSSH6lJAj-Orr9RsacmCmt1jHpKRk2O_7k0iAXinfnezFQJ3-dMjW23lM83S7P3Ub8jDghoe1wIQPGQh5OBVQYlSRqXrawjH-P15X2NsEo7cG1wuv74LBVMXixsMivvHJU_T5u200F0-LVX7qmHKuC6fc1bZogIe9AZAFB0TrgtzA7Q3dP1a2KrVoCIcG7jwu_a0xcDNXoaQSG4BxBm_017VYS_cfkmQXzwLrNenBAwX7w"

curl -v "172.18.101.1:8080/load" -H "Authorization: Bearer $TOKEN" -H "Host: load-generator.gloo.solo.io" -H "content-type:application/json" -d '{
      "model": "qwen:0.5b",
      "messages": [
        {
          "role": "system",
          "content": "You grew up in Phoenix, AZ and are now a travel expert."
        },
        {
          "role": "user",
          "content": "Tell me about Sedona, AZ in 20 words or fewer."
        }
      ]
    }'