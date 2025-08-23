# Simulador Interativo de R₀ — Evolução de Casos

Este projeto apresenta um **aplicativo em R Shiny** exportado com **Shinylive**, que permite simular e visualizar a evolução de casos em diferentes cenários epidemiológicos.  
Com ele, é possível comparar valores distintos de R₀ e ciclos de transmissão, observando como pequenas variações podem impactar drasticamente a curva de crescimento de uma epidemia.

## Limitações

Este simulador é um **modelo simplificado e determinístico**, que assume crescimento exponencial puro a partir do valor de R₀ informado.  
Não considera fatores como:
- imunidade populacional adquirida ao longo do tempo,  
- heterogeneidade de contatos,  
- medidas de saúde pública,  
- dinâmica estocástica das transmissões,  
- nem variações biológicas e sociais.  

👉 Portanto, sua finalidade é **exclusivamente educacional**, servindo como ferramenta para compreender o conceito de **R₀** e os efeitos teóricos da taxa de reprodução sobre a propagação de uma doença.  
Ele **não deve ser usado** como previsão realista de epidemias ou como base para decisões clínicas e de saúde pública.


## Demonstração Online
👉 [Acesse o app no GitHub Pages](https://SEU_USUARIO.github.io/NOME_DO_REPOSITORIO/)

---

## Sobre o Autor

👨‍⚕️ **Henrique Alvarenga**  
Médico Psiquiatra, graduado em Medicina pela **Universidade Federal de Minas Gerais (UFMG, 1997)**, com residência em Psiquiatria pelo **Hospital das Clínicas da UFMG (2000)**.  
Especialista em **Psicoterapia Cognitiva-Construtivista** (Núcleo de Psicoterapia Cognitiva de São Paulo).  
Também é **Bacharel em Direito** pelo Centro Universitário Presidente Tancredo de Almeida Neves (UNIPTAN, 2013).  

Atualmente é:
- **Professor do Curso de Medicina (UNIPTAN)** — disciplinas de **Métodos de Ensino e Pesquisa** e **Saúde Mental**.  
- **Professor do Curso de Medicina (UFSJ)** — disciplinas de **Psiquiatria** e **Psicopatologia**.  
- **Mestre em Ensino em Saúde pela UNIFENAS**.  

Com ampla experiência em **psiquiatria clínica, neurociências e pesquisa**, atua na interface entre **ciência, tecnologia, filosofia, comportamento e emoção**, explorando também o uso de **linguagens de programação (R, Python)** e **inteligência artificial** para inovação em saúde e educação médica.

📚 **Currículo Lattes**: [http://lattes.cnpq.br/6147640440978297](http://lattes.cnpq.br/6147640440978297)  
🌐 **Site pessoal**: [henriquealvarenga.com](https://www.henriquealvarenga.com)

---

## Funcionalidades do App

- Ajuste dinâmico dos parâmetros de **R₀** e **número de ciclos**.  
- Comparação de **dois cenários simultaneamente**.  
- Exibição de **gráfico interativo** (escala linear ou logarítmica).  
- **Tabela de resultados formatada** no padrão brasileiro (vírgula como decimal).  
- **Download em CSV** dos resultados para análise posterior.  

Este simulador é ideal para fins **educacionais**, para o **ensino de epidemiologia** e para a **demonstração prática do impacto da taxa de reprodução (R₀)** em surtos infecciosos.

---

## Licença
Este projeto está licenciado sob a [MIT License](LICENSE).